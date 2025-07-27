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
    func rpcDidConnect(_ rpc: SwordRPC)

    /// Called when the RPC client disconnects from Discord.
    /// - Parameters:
    ///   - rpc: The RPC instance that disconnected.
    ///   - code: The disconnection code, if available.
    ///   - msg: The disconnection message, if available.
    func rpcDidDisconnect(_ rpc: SwordRPC, code: Int?, message msg: String?)

    /// Called when the RPC client receives an error from Discord.
    /// - Parameters:
    ///   - rpc: The RPC instance that received the error.
    ///   - code: The error code.
    ///   - msg: The error message.
    func rpcDidReceiveError(_ rpc: SwordRPC, code: Int, message msg: String)

    /// Called when a join game event is received.
    /// - Parameters:
    ///   - rpc: The RPC instance.
    ///   - secret: The join secret string.
    func rpcDidJoinGame(_ rpc: SwordRPC, secret: String)

    /// Called when a spectate game event is received.
    /// - Parameters:
    ///   - rpc: The RPC instance.
    ///   - secret: The spectate secret string.
    func rpcDidSpectateGame(_ rpc: SwordRPC, secret: String)

    /// Called when a join request is received from another user.
    /// - Parameters:
    ///   - rpc: The RPC instance.
    ///   - request: The join request details.
    ///   - secret: The join secret string.
    func rpcDidReceiveJoinRequest(_ rpc: SwordRPC, request: JoinRequest, secret: String)
}

/// Default implementations do nothing, this just allows us to avoid using optionals.
extension SwordRPCDelegate {
    public func rpcDidConnect(_ rpc: SwordRPC) {}
    public func rpcDidDisconnect(_ rpc: SwordRPC, code: Int?, message msg: String?) {}
    public func rpcDidReceiveError(_ rpc: SwordRPC, code: Int, message msg: String) {}
    public func rpcDidJoinGame(_ rpc: SwordRPC, secret: String) {}
    public func rpcDidSpectateGame(_ rpc: SwordRPC, secret: String) {}
    public func rpcDidReceiveJoinRequest(_ rpc: SwordRPC, request: JoinRequest, secret: String) {}
}
