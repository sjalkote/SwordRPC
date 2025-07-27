//
//  SwordRPC.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation
import Socket

/// SwordRPC is a Swift library for using Discord's Rich Presence IPC protocol. See the docs for steps on uage.
///
/// This class manages the connection to Discord, handles sending and receiving
/// rich presence updates, and provides event handlers for Discord events.
///
/// ## Usage:
/// - Initialize with your Discord application ID.
/// - Call ``connect()`` to establish a connection to the Discord client.
/// - Use ``setPresence(_:)`` to update the user's rich presence with the specified ``RichPresence`` state.
/// - Implement the ``SwordRPCDelegate`` protocol or set handler closures for event callbacks.
public class SwordRPC {
    
    // MARK: App Info
    /// The Discord application ID for your rich presence, found in the developer portal.
    public let appId: String
    /// The interval (in seconds) between handler events.
    public var handlerInterval: TimeInterval
    /// Whether to automatically register the application with Discord's URL scheme (`discord-appid://`)
    public let autoRegister: Bool
    /// The Steam ID to associate with the session, if any.
    public let steamId: String?
    
    // MARK: Technical stuff
    /// The process identifier (PID) of the current process.
    let pid: Int32
    /// The underlying IPC socket connection to Discord.
    var socket: Socket? = nil
    /// JSON encoder for encoding payloads.
    let encoder = JSONEncoder()
    /// JSON decoder for decoding payloads.
    let decoder = JSONDecoder()
    /// The current rich presence state.
    var presence: RichPresence? = nil
    
    // MARK: Event Handlers
    /// Delegate for SwordRPC events.
    public weak var delegate: SwordRPCDelegate? = nil
    /// Handler called when a connection is established.
    var connectHandler:      ((_ rpc: SwordRPC) -> ())? = nil
    /// Handler called when a disconnection occurs.
    var disconnectHandler:   ((_ rpc: SwordRPC, _ code: Int?, _ msg: String?) -> ())? = nil
    /// Handler called when an error occurs.
    var errorHandler:        ((_ rpc: SwordRPC, _ code: Int, _ msg: String) -> ())? = nil
    /// Handler called when a user joins the game/activity.
    var joinGameHandler:     ((_ rpc: SwordRPC, _ secret: String) -> ())? = nil
    /// Handler called when a user sends a spectate game request.
    var spectateGameHandler: ((_ rpc: SwordRPC, _ secret: String) -> ())? = nil
    /// Handler called when a user sends a join game request.
    var joinRequestHandler:  ((_ rpc: SwordRPC, _ request: JoinRequest, _ secret: String) -> ())? = nil
    
    /// Initializes a new SwordRPC instance.
    /// - Parameters:
    ///     - appId: Your Discord application ID.
    ///     - handlerInterval: The interval in seconds between handler events. Default is `1` second.
    ///     - autoRegister: Whether to automatically register the application with Discord's URL scheme. Default is `true`.
    ///     - steamId: Optional Steam ID to associate with the session. Leave `nil` if not needed.
    public init(
        appId: String,
        handlerInterval: TimeInterval = 1,
        autoRegister: Bool = true,
        steamId: String? = nil
    ) {
        self.appId = appId
        self.handlerInterval = handlerInterval
        self.autoRegister = autoRegister
        self.steamId = steamId
        
        self.pid = ProcessInfo.processInfo.processIdentifier
        self.encoder.dateEncodingStrategy = .secondsSince1970
        
        self.createSocket()
        
        self.registerUrl()
    }

    /// Connects to the Discord IPC socket and performs the handshake.
    /// - Returns: `.success` (Void) if connected, or `.failure` with a specific ``SwordRPCError`` if the connection fails.
    public func connect() -> Result<Void, SwordRPCError> {
        let tmp = NSTemporaryDirectory()
        
        guard let socket = self.socket else {
            print("[SwordRPC] Unable to connect")
            return .failure(.socketUnavailable)
        }
        
        for i in 0 ..< 10 {
            try? socket.connect(to: "\(tmp)/discord-ipc-\(i)")
            
            guard !socket.isConnected else {
                self.handshake()
                self.receive()
                
                self.subscribe("ACTIVITY_JOIN")
                self.subscribe("ACTIVITY_SPECTATE")
                self.subscribe("ACTIVITY_JOIN_REQUEST")
                
                print("[SwordRPC] Connected to Discord after \(i+1) attempts")
                return .success(Void())
            }
        }
        
        print("[SwordRPC] Discord not detected")
        return .failure(.discordNotDetected)
    }
    
    /// Disconnects from the Discord IPC socket and notifies the delegate.
    public func disconnect() {
        if let socket = self.socket {
            socket.close()
            self.delegate?.rpcDidDisconnect(self, code: 0, message: nil)
        } else {
            print("[SwordRPC] Already disconnected")
        }
    }
    
    /// Updates the presence state with the provided ``RichPresence``.
    /// - Parameter presence: The rich presence to set.
    public func setPresence(_ presence: RichPresence) {
        self.presence = presence
    }
    
    /// Replies to a user's ``JoinRequest`` with the specified ``JoinReply``.
    /// - Parameters:
    ///  - request: The join request to reply to.
    ///  - reply: The reply to send back to the requester.
    public func reply(to request: JoinRequest, with reply: JoinReply) {
        let json = """
        {
          "cmd": "\(
            reply == .yes ? "SEND_ACTIVITY_JOIN_INVITE" : "CLOSE_ACTIVITY_JOIN_REQUEST"
          )",
          "args": {
            "user_id": "\(request.userId)"
          }
        }
        """
        
        try? self.send(json, .frame)
    }
    
}
