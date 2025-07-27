//
//  RPC.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation
import Socket

/// Handles communication with the Discord RPC socket.
///
/// By marking this as @unchecked Sendable, we take responsibility for preventing race conditions and ensuring thread safety.
extension SwordRPC: @unchecked Sendable {

    /// Creates a new socket for RPC communication.
    func createSocket() {
        do {
            self.socket = try Socket.create(family: .unix, proto: .unix)
            try self.socket?.setBlocking(mode: false)
        } catch {
            guard let error = error as? Socket.Error else {
                return
            }

            print("[SwordRPC] Error creating rpc socket: \(error)")
        }
    }

    /// Sends a message with the specified operation code to the Discord RPC socket.
    /// - Parameters:
    ///   - msg: The JSON string message to send.
    ///   - op: The operation code to use.
    /// - Throws: An error if the socket write fails.
    func send(_ msg: String, _ op: OP) throws {
        let payload = msg.data(using: .utf8)!

        var buffer = UnsafeMutableRawBufferPointer.allocate(
            byteCount: 8 + payload.count,
            alignment: 1
        )

        defer { buffer.deallocate() }

        buffer.copyBytes(from: payload)
        buffer[8...] = buffer[..<payload.count]
        buffer.storeBytes(of: op.rawValue, as: UInt32.self)
        buffer
            .storeBytes(
                of: UInt32(payload.count),
                toByteOffset: 4,
                as: UInt32.self
            )

        try self.socket?.write(from: buffer.baseAddress!, bufSize: buffer.count)
    }

    /// Starts receiving messages from the Discord RPC socket asynchronously.
    /// Handles incoming payloads and dispatches them to the appropriate handler.
    func receive() {
        Task { [weak self] in
            guard let self = self else { print("[SwordRPC] Failed to unwrap self in receive()"); return; }
            try? await Task.sleep(nanoseconds: UInt64(self.handlerInterval) * 1_000_000)
            guard let isConnected = self.socket?.isConnected, isConnected else {
                self.disconnectHandler?(self, nil, nil)
                self.delegate?
                    .rpcDidDisconnect(self, code: nil, message: nil)
                return
            }

            self.receive()

            do {
                let headerPtr = UnsafeMutablePointer<Int8>.allocate(capacity: 8)
                let headerRawPtr = UnsafeRawPointer(headerPtr)

                defer {
                    free(headerPtr)
                }

                var response = try self.socket?.read(
                    into: headerPtr,
                    bufSize: 8,
                    truncate: true
                )

                guard response! > 0 else {
                    return
                }

                let opValue = headerRawPtr.load(as: UInt32.self)
                let length = headerRawPtr.load(
                    fromByteOffset: 4,
                    as: UInt32.self
                )

                guard length > 0, let op = OP(rawValue: opValue) else {
                    return
                }

                let payloadPtr = UnsafeMutablePointer<Int8>.allocate(
                    capacity: Int(length)
                )

                defer {
                    free(payloadPtr)
                }

                response = try self.socket?
                    .read(
                        into: payloadPtr,
                        bufSize: Int(length),
                        truncate: true
                    )

                guard response! > 0 else {
                    return
                }

                let data = Data(
                    bytes: UnsafeRawPointer(payloadPtr),
                    count: Int(length)
                )

                self.handlePayload(op, data)

            } catch {
                return
            }
        }
    }

    /// Performs the initial handshake with Discord using the client ID.
    func handshake() {
        do {
            let json = """
                {
                  "v": 1,
                  "client_id": "\(self.appId)"
                }
                """

            try self.send(json, .handshake)
        } catch {
            print("[SwordRPC] Unable to handshake with Discord")
            self.socket?.close()
        }
    }

    /// Subscribes to a specific Discord event.
    /// - Parameter event: The event name to subscribe to.
    func subscribe(_ event: String) {
        let json = """
            {
              "cmd": "SUBSCRIBE",
              "evt": "\(event)",
              "nonce": "\(UUID().uuidString)"
            }
            """

        try? self.send(json, .frame)
    }

    /// Handles an incoming payload from Discord based on the operation code.
    /// - Parameters:
    ///   - op: The operation code of the payload.
    ///   - json: The payload data as JSON.
    func handlePayload(_ op: OP, _ json: Data) {
        switch op {
        case .close:
            let data = self.decode(json)
            let code = data["code"] as! Int
            let message = data["message"] as! String
            self.socket?.close()
            self.disconnectHandler?(self, code, message)
            self.delegate?
                .rpcDidDisconnect(self, code: code, message: message)

        case .ping:
            try? self.send(String(data: json, encoding: .utf8)!, .pong)

        case .frame:
            self.handleEvent(self.decode(json))

        default:
            return
        }
    }

    /// Handles a specific Discord event and dispatches it to the appropriate handler or delegate method.
    /// - Parameter data: The event data as a dictionary.
    func handleEvent(_ data: [String: Any]) {
        guard let evt = data["evt"] as? String, let event = Event(rawValue: evt) else {
            return
        }

        let data = data["data"] as! [String: Any]

        switch event {
        case .error:
            let code = data["code"] as! Int
            let message = data["message"] as! String
            self.errorHandler?(self, code, message)
            self.delegate?
                .rpcDidReceiveError(self, code: code, message: message)

        case .join:
            let secret = data["secret"] as! String
            self.joinGameHandler?(self, secret)
            self.delegate?.rpcDidJoinGame(self, secret: secret)

        case .joinRequest:
            let requestData = data["user"] as! [String: Any]
            let joinRequest = try! self.decoder.decode(
                JoinRequest.self,
                from: self.encode(requestData)
            )
            let secret = data["secret"] as! String
            self.joinRequestHandler?(self, joinRequest, secret)
            self.delegate?
                .rpcDidReceiveJoinRequest(
                    self,
                    request: joinRequest,
                    secret: secret
                )

        case .ready:
            self.connectHandler?(self)
            self.delegate?.rpcDidConnect(self)
            self.updatePresence()

        case .spectate:
            let secret = data["secret"] as! String
            self.spectateGameHandler?(self, secret)
            self.delegate?.rpcDidSpectateGame(self, secret: secret)
        }
    }

    /// Updates the user's presence after an optional delay, using a `Task` and scheduling a regular update.
    /// - Parameter afterDelay: The delay in seconds before updating presence. Default is **5 seconds**.
    func updatePresence(afterDelay: TimeInterval = 5) {
        Task { [weak self] in
            guard let self = self else { return }
            try? await Task.sleep(nanoseconds: UInt64(afterDelay * 1_000_000_000))
            self.updatePresence()

            guard let presence = self.presence else {
                return
            }

            let json = """
                    {
                      "cmd": "SET_ACTIVITY",
                      "args": {
                        "pid": \(self.pid),
                        "activity": \(String(data: try! self.encoder.encode(presence), encoding: .utf8)!)
                      },
                      "nonce": "\(UUID().uuidString)"
                    }
                    """

            try? self.send(json, .frame)
            self.presence = nil
        }
    }

}
