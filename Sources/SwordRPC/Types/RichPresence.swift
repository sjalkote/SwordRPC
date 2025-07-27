//
//  RichPresence.swift
//  SwordRPC
//
//  Created by Alejandro Alonso
//  Copyright © 2017 Alejandro Alonso. All rights reserved.
//

import Foundation

/// Represents the [Discord Activity object](https://discord.com/developers/docs/events/gateway-events#activity-object)
/// containing all the information for the rich presence.
///
/// Use this struct to configure rich presence features such as images, party information, and interactive buttons.
/// Each property maps to a field in the Discord Activity API, allowing for detailed customization of the user's presence.
///
/// - SeeAlso: [Discord Activity object](https://discord.com/developers/docs/events/gateway-events#activity-object)
public struct RichPresence: Encodable {
    /// Images and hover texts for the rich presence.
    ///
    /// Discord supports one large image and one small image. Each image also has optional text that appears when hovering over the image.
    /// - SeeAlso: [Discord activity assets](https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-assets)
    /// - SeeAlso: ``Assets`` struct for information about using assets.
    public var assets: Assets = Assets()
    /// The first line on the rich presence, below the activity name.
    ///
    /// Intended for what the player is currently doing. Use `nil` to hide this field.
    /// - SeeAlso: [Discord activity structure](https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-structure)
    public var details: String?
    /// Whether or not the activity is an instanced game session.
    ///
    /// - SeeAlso: [Discord activity structure](https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-structure)
    /// - Note: Defaults to `true`. Set to `false` if the activity is not an instanced session.
    public var instance: Bool = true
    /// Information for the current party of the player, shows in parenthesis next to ``state``.
    ///
    /// Used to show party size, max size, and party ID for join/spectate features
    /// - SeeAlso: [Discord activity party](https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-party)
    public var party: Party?
    /// Secrets in order to use activity joining / spectating / match features.
    ///
    /// - Important: **Buttons cannot be used with secrets**, they are mutually exclusive. This is a limitation of Discord's API.
    /// It's recommended to leave this `nil` so that you can use buttons instead.
    /// - SeeAlso: [Discord activity secrets](https://discord.com/developers/docs/events/gateway-events#activity-object-activity-secrets)
    public var secrets: Secrets?
    /// The second line on the rich presence, below the details field.
    ///
    /// Intended for the user's current party status, or text used for a custom status. Use `nil` to hide this field.
    /// - SeeAlso: [Discord activity structure](https://discord.com/developers/docs/events/gateway-events#activity-object-activity-structure)
    public var state: String?
    /// Unix timestamps for the start or end show elapsed or remaining time in the activity.
    ///
    /// - SeeAlso: [Discord activity timestamps](https://discord.com/developers/docs/events/gateway-events#activity-object-activity-timestamps)
    /// - Note: For Listening and Watching activities, you can include both start and end timestamps to **display a time bar**.
    public var timestamps: Timestamps = Timestamps()
    /// The type of rich presence activity status.
    ///
    /// - SeeAlso: [Discord activity types](https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-types)
    /// - Important: Defaults to ``ActivityType/playing``. See `ActivityType` for all valid values.
    public var type: ActivityType? = .playing
    /// Buttons that can be displayed below the rich presence, opening a link when clicked.
    ///
    /// - SeeAlso: [Discord activity buttons](https://discord.com/developers/docs/events/gateway-events#activity-object-activity-buttons)
    /// - Important: Discord supports a maximum of **2 buttons** per activity. Any additional buttons will be _removed_ automatically.
    /// - Warning: **Do not use secrets** if you need buttons, as they are mutually exclusive. This is a limitation of Discord's API.
    public var buttons: [Button]? {
        didSet {
            if let buttons = self.buttons, buttons.count > 2 {
                self.buttons = Array(buttons.prefix(2))
                print("[SwordRPC]: Only 2 buttons are supported by Discord. Removing extra buttons.")
            }
        }
    }

    public init() {}
}

extension RichPresence {
    /// Represents the [Timestamps](https://discord.com/developers/docs/events/gateway-events#activity-object-activity-timestamps) object.
    ///
    /// Use this struct to specify start and end times for the activity, enabling elapsed or remaining time displays in rich presence.
    /// Both `start` and `end` are optional and can be used independently or together.
    /// - Note: If the activity type is ``ActivityType/listening`` or ``ActivityType/watching``, you can include both `start` and `end` timestamps to **display a time bar**.
    /// - SeeAlso: [Discord Activity Timestamps](https://discord.com/developers/docs/events/gateway-events#activity-object-activity-timestamps)
    public struct Timestamps: Encodable {
        /// Internal property for the start unix timestamp.
        private var _start: Date? = nil
        /// Internal property for the end unix timestamp.
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

    /// Represents the [Assets](https://discord.com/developers/docs/events/gateway-events#activity-object-activity-assets) object.
    ///
    /// Use this struct to specify large and small images, along with their hover texts, for the rich presence activity.
    /// Both images are optional, and each can have an associated text that appears when hovering over the image in Discord.
    ///
    /// - SeeAlso: [Discord Activity Assets](https://discord.com/developers/docs/events/gateway-events#activity-object-activity-assets)
    public struct Assets: Encodable {
        /// The large image for the rich presence.
        ///
        /// Can either be:
        /// - The asset key corresponding to the key of image you uploaded in the Developer portal,
        /// - Media Proxy in the format  `mp:{image_id}` where `{image_id}` is from `https://media.discordapp.net/{image_id}`.
        public var largeImage: String? = nil
        /// Text that appears when hovering over the large image.
        public var largeText: String? = nil
        /// The small image for the rich presence, shows in the corner of the large image.
        ///
        /// Can either be:
        /// - The asset key corresponding to the key of image you uploaded in the Developer portal,
        /// - Media Proxy in the format  `mp:{image_id}` where `{image_id}` is from `https://media.discordapp.net/{image_id}`.
        public var smallImage: String? = nil
        /// Text that appears when hovering over the small image.
        public var smallText: String? = nil

        /// Used to encode the assets to the correct format in JSON.
        enum CodingKeys: String, CodingKey {
            case largeImage = "large_image"
            case largeText = "large_text"
            case smallImage = "small_image"
            case smallText = "small_text"
        }
    }
    
    /// Represents the activity [Button](https://discord.com/developers/docs/events/gateway-events#activity-object-activity-buttons) objects.
    ///
    /// Use this struct to define a button that appears below the rich presence, opening a URL when clicked.
    /// Each button must have a label and a valid URI. Discord supports up to 2 buttons per activity.
    ///
    /// - SeeAlso: [Discord Activity Buttons](https://discord.com/developers/docs/topics/gateway-events#activity-object-activity-buttons)
    public struct Button: Encodable {
        /// The label to display on the button.
        public var label: String
        /// The URL to open when the button is clicked. Must be a valid URI.
        public var url: String
        public init(label: String, url: String) {self.label = label; self.url = url}
    }

    /// Party information for the activity, such as party ID and size.
    ///
    /// Used to show party size, max size, and party ID for join/spectate features.
    public struct Party: Encodable {
        /// ID of the party.
        public var id: String? = nil
        /// The maximum size of the party.
        public var max: Int? = nil
        /// The current size of the party.
        public var size: Int? = nil

        /// Used to encode the party to the correct format in JSON.
        enum CodingKeys: String, CodingKey {
            case id
            case size
        }

        /// Encodes the party information to JSON format.
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(self.id, forKey: .id)

            guard let max = self.max, let size = self.size else {
                return
            }

            try container.encode([size, max], forKey: .size)
        }
    }

    /// Secrets for join, match, and spectate features in the activity.
    ///
    /// Used to enable joining, spectating, or matching in a game session.
    /// - Important: The Discord API does not support using buttons when secrest are being used.
    public struct Secrets: Encodable {
        /// Secret for joining a party.
        public var join: String? = nil
        /// Secret for a specific match.
        public var match: String? = nil
        /// Secret for spectating a game.
        public var spectate: String? = nil
    }
}
