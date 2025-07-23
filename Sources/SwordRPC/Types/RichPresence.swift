//
//  RichPresence.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

public struct RichPresence: Encodable {
    public var assets = Assets()
    public var details = ""
    public var instance = true
    public var party = Party()
    public var secrets = Secrets()
    public var state = ""
    public var timestamps = Timestamps()

    public init() {}
}

extension RichPresence {
    /// Creates elapsed/remaining timestamps for the activity.
    public struct Timestamps: Encodable {
        private var _start: Date? = nil
        private var _end: Date? = nil

        /// The starting unix timestamp of the activity. Use this to have an "elapsed" timer.
        public var start: Date? {
            get { _start }
            // Discord API expects an Int, so we round to avoid passing a Double
            set { _start = newValue.map { Date(timeIntervalSince1970: $0.timeIntervalSince1970.rounded()) } }
        }
        /// The ending unix timestamp of the activity. Use this to have a "remaining" timer.
        public var end: Date? {
            get { _end }
            // Discord API expects an Int, so we round to avoid passing a Double
            set { _end = newValue.map { Date(timeIntervalSince1970: $0.timeIntervalSince1970.rounded()) } }
        }
    }

    public struct Assets: Encodable {
        public var largeImage: String? = nil
        public var largeText: String? = nil
        public var smallImage: String? = nil
        public var smallText: String? = nil

        enum CodingKeys: String, CodingKey {
            case largeImage = "large_image"
            case largeText = "large_text"
            case smallImage = "small_image"
            case smallText = "small_text"
        }
    }

    public struct Party: Encodable {
        public var id: String? = nil
        public var max: Int? = nil
        public var size: Int? = nil

        enum CodingKeys: String, CodingKey {
            case id
            case size
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(self.id, forKey: .id)

            guard let max = self.max, let size = self.size else {
                return
            }

            try container.encode([size, max], forKey: .size)
        }
    }

    public struct Secrets: Encodable {
        public var join: String? = nil
        public var match: String? = nil
        public var spectate: String? = nil
    }
}
