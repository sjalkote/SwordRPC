//
//  JoinRequest.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

public struct JoinRequest: Decodable {
    public let avatar: String
    public let discriminator: String
    public let userId: String
    public let username: String

    enum CodingKeys: String, CodingKey {
        case avatar
        case discriminator
        case userId = "id"
        case username
    }
}
