//
//  Events.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Provides event handler registration methods for SwordRPC.
///
/// Use these methods to set closures that respond to RPC events
/// like connection, disconnection, errors, joining, and spectating.
extension SwordRPC {
    /// Registers a handler to be called when the RPC client connects to Discord.
    /// - Parameter handler: Closure called with the SwordRPC instance.
    public func onConnect(handler: @escaping (_ rpc: SwordRPC) -> ()) {
        self.connectHandler = handler
    }

    /// Registers a handler to be called when the RPC client disconnects from Discord.
    /// - Parameter handler: Closure called with the SwordRPC instance, disconnection code, and message.
    public func onDisconnect(handler: @escaping (_ rpc: SwordRPC, _ code: Int?, _ msg: String?) -> ()) {
        self.disconnectHandler = handler
    }

    /// Registers a handler to be called when the RPC client receives an error from Discord.
    /// - Parameter handler: Closure called with the SwordRPC instance, error code, and message.
    public func onError(handler: @escaping (_ rpc: SwordRPC, _ code: Int, _ msg: String) -> ()) {
        self.errorHandler = handler
    }

    /// Registers a handler to be called when another user joins the game/activity.
    /// - Parameter handler: Closure called with the SwordRPC instance and join secret.
    public func onJoinGame(handler: @escaping (_ rpc: SwordRPC, _ secret: String) -> ()) {
        self.joinGameHandler = handler
    }

    /// Registers a handler to be called when a spectate game request is received from another user.
    /// - Parameter handler: Closure called with the SwordRPC instance and spectate secret.
    public func onSpectateGame(handler: @escaping (_ rpc: SwordRPC, _ secret: String) -> ()) {
        self.spectateGameHandler = handler
    }

    /// Registers a handler to be called when a join request is received from another user.
    /// - Parameter handler: Closure called with the SwordRPC instance, join request, and join secret.
    public func onJoinRequest(handler: @escaping (_ rpc: SwordRPC, _ request: JoinRequest, _ secret: String) -> ()) {
        self.joinRequestHandler = handler
    }
}
