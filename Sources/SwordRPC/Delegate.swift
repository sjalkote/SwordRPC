//
//  Delegate.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Protocol for handling state changes and receiving client events.
///
/// Implement this protocol to handle events such as connection,  disconnection, errors, join/spectate requests, and join requests from other users.
public protocol SwordRPCDelegate: AnyObject {
    /// Called when the RPC client successfully connects to Discord.
    /// - Parameter rpc: The SwordRPC instance that connected.
    func swordRPCDidConnect(_ rpc: SwordRPC)

    /// Called when the RPC client disconnects from Discord.
    /// - Parameters:
    ///   - rpc: The SwordRPC instance that disconnected.
    ///   - code: The disconnection code, if available.
    ///   - msg: The disconnection message, if available.
    func swordRPCDidDisconnect(_ rpc: SwordRPC, code: Int?, message msg: String?)

    /// Called when the RPC client receives an error from Discord.
    /// - Parameters:
    ///   - rpc: The SwordRPC instance that received the error.
    ///   - code: The error code.
    ///   - msg: The error message.
    func swordRPCDidReceiveError(_ rpc: SwordRPC, code: Int, message msg: String)

    /// Called when a join game event is received.
    /// - Parameters:
    ///   - rpc: The SwordRPC instance.
    ///   - secret: The join secret string.
    func swordRPCDidJoinGame(_ rpc: SwordRPC, secret: String)

    /// Called when a spectate game event is received.
    /// - Parameters:
    ///   - rpc: The SwordRPC instance.
    ///   - secret: The spectate secret string.
    func swordRPCDidSpectateGame(_ rpc: SwordRPC, secret: String)

    /// Called when a join request is received from another user.
    /// - Parameters:
    ///   - rpc: The SwordRPC instance.
    ///   - request: The join request details.
    ///   - secret: The join secret string.
    func swordRPCDidReceiveJoinRequest(_ rpc: SwordRPC, request: JoinRequest, secret: String)
}

extension SwordRPCDelegate {
    /// Default implementation does nothing.
    public func swordRPCDidConnect(_ rpc: SwordRPC) {}
    /// Default implementation does nothing.
    public func swordRPCDidDisconnect(_ rpc: SwordRPC, code: Int?, message msg: String?) {}
    /// Default implementation does nothing.
    public func swordRPCDidReceiveError(_ rpc: SwordRPC, code: Int, message msg: String) {}
    /// Default implementation does nothing.
    public func swordRPCDidJoinGame(_ rpc: SwordRPC, secret: String) {}
    /// Default implementation does nothing.
    public func swordRPCDidSpectateGame(_ rpc: SwordRPC, secret: String) {}
    /// Default implementation does nothing.
    public func swordRPCDidReceiveJoinRequest(_ rpc: SwordRPC, request: JoinRequest, secret: String) {}
}
