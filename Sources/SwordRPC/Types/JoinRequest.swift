//
//  JoinRequest.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

/// Represents a join request from a Discord user.
public struct JoinRequest: Decodable {
    /// The user's avatar hash.
    public let avatar: String

    /// The user's Discord discriminator (the 4-digit tag).
    ///
    /// - Warning: Discord deprecated discriminators in favor of unique ``username``s.
    public let discriminator: String

    /// The user's unique Discord ID.
    public let userId: String

    /// The user's Discord username.
    public let username: String

    /// Used to convert into JSON properties expected by the Discord API.
    enum CodingKeys: String, CodingKey {
        case avatar
        case discriminator
        case userId = "id"
        case username
    }
}
