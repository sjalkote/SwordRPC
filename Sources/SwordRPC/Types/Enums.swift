//
//  Enums.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Operation codes used for communication between the client and Discord IPC.
enum OP: UInt32 {
    /// Initiates a handshake with Discord.
    case handshake
    /// Sends or receives a data frame.
    case frame
    /// Closes the connection.
    case close
    /// Ping message to check connection.
    case ping
    /// Pong response to a ping.
    case pong
}

/// Events that can be received from or sent to Discord.
///
/// - SeeAlso: [Discord Activity Flags](https://discord.com/developers/docs/events/gateway-events#activity-object-activity-flags)
enum Event: String {
    /// An error occurred.
    case error = "ERROR"
    /// User joined an activity.
    case join = "ACTIVITY_JOIN"
    /// User requested to join an activity.
    case joinRequest = "ACTIVITY_JOIN_REQUEST"
    /// Connection is ready.
    case ready = "READY"
    /// User started spectating an activity.
    case spectate = "ACTIVITY_SPECTATE"
}

/// Reply options used when a user sends a join request to your activity.
public enum JoinReply: Int, Codable {
    /// Deny the join request.
    case no = 0
    /// Accept the join request.
    case yes = 1
    /// Ignore the join request.
    case ignore = 2
}

/// The activity type will be displayed as the user's status. For example, ``playing`` will display as "**Playing {activity}**".
///
/// You can view the documentation for each of the enum cases to see what the preview would look like on the Discord status.
/// - SeeAlso: [Discord activity types](https://discord.com/developers/docs/developer-tools/game-sdk#activitytype-enum)
public enum ActivityType: Int, Codable {
    /// Playing {name}
    case playing = 0
    /// Streaming {details}
    case streaming = 1
    /// Listening to {name}
    case listening = 2
    /// Watching {name}
    case watching = 3
    /// {emoji} {state}
    ///
    /// Similar to just setting a custom status in Discord.
    case custom = 4
    /// Competing in {name}
    case competing = 5
}

/// Represents specific type of errors that can occur in SwordRPC, allows for more specific error handling.
public enum SwordRPCError: Error {
    /// Occurs when SwordRPC starts successfully but fails to connect to Discord.
    case discordNotDetected
    /// Occurs when SwordRPC was unable to connect to the IPC socket.
    case socketUnavailable
}
