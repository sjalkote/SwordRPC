//
//  Enums.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

enum OP: UInt32 {
    case handshake
    case frame
    case close
    case ping
    case pong
}

enum Event: String {
    case error = "ERROR"
    case join = "ACTIVITY_JOIN"
    case joinRequest = "ACTIVITY_JOIN_REQUEST"
    case ready = "READY"
    case spectate = "ACTIVITY_SPECTATE"
}

public enum JoinReply: Int, Codable {
    case no = 0
    case yes = 1
    case ignore = 2
}

/// See also: https://discord.com/developers/docs/developer-tools/game-sdk#activitytype-enum
public enum ActivityType: Int, Codable {
    case playing = 0
    case streaming = 1
    case listening = 2
    case watching = 3
    case custom = 4
    case competing = 5
}

public enum SwordRPCError: Error {
    case discordNotDetected
    case socketUnavailable
}
