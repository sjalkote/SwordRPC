# SwordRPC - A Discord Rich Presence Library for Swift

[![Swift Version](https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat-square)](https://swift.org)
[![Tag](https://img.shields.io/github/tag/sjalkote/SwordRPC.svg?style=flat-square&label=release)](https://github.com/sjalkote/SwordRPC/releases)

This fork provides a more up-to-date and maintained version of the SwordRPC library, which allows you to **integrate Discord Rich Presence into your Swift apps**.
The code has been heavily documented and the package has been updated with new features and fixes, hopefully making it somewhat more enjoyable to use.

Some of the changes so far include:

- Source updated for Swift 5.0 or higher, support for Swift Package Manager, and updated the Socket dependency.
- Extensive documentation with DocC & reformatted source code (**In progress**)
- Timestamp `Double` -> `Int` auto conversion that integrates nicely with any existing usages out of the box.
- uhhh more stuff in progress

> [!TIP]
> Open an issue or PR if you have any suggestions/contributions/bugs.

## Requirements
1. macOS or Linux
2. Swift 5.0 or greater

## Adding SwordRPC

### Swift Package Manager

1. In your Xcode project, go to **File > Add Package Dependencies...**
2. Enter the repo URL `https://github.com/sjalkote/SwordRPC.git` and press the button to add it
3. Yeah that's it lol

## Example
### Callbacks
```swift
import SwordRPC

/// Additional arguments:
/// handlerInterval: Int = 1000 (decides how fast to check discord for updates, 1000ms = 1s)
/// autoRegister: Bool = true (automatically registers your application to discord's url scheme (discord-appid://))
/// steamId: String? = nil (this is for steam games on these platforms)
let rpc = SwordRPC(appId: "123")

rpc.onConnect { rpc in
  var presence = RichPresence()
  presence.details = "Ranked | Mode: \(mode)"
  presence.state = "In a Group"
  presence.timestamps.start = Date()
  presence.timestamps.end = Date() + 600 // 600s = 10m
  presence.assets.largeImage = "map1"
  presence.assets.largeText = "Map 1"
  presence.assets.smallImage = "character1"
  presence.assets.smallText = "Character 1"
  presence.party.max = 5
  presence.party.size = 3
  presence.party.id = "partyId"
  presence.secrets.match = "matchSecret"
  presence.secrets.join = "joinSecret"
  presence.secrets.joinRequest = "joinRequestSecret"

  rpc.setPresence(presence)
}

rpc.onDisconnect { rpc, code, msg in
  print("It appears we have disconnected from Discord")
}

rpc.onError { rpc, code, msg in
  print("It appears we have discovered an error!")
}

rpc.onJoinGame { rpc, secret in
  print("We have found us a join game secret!")
}

rpc.onSpectateGame { rpc, secret in
  print("Our user wants to spectate!")
}

rpc.onJoinRequest { rpc, request, secret in
  print("Some user wants to play with us!")
  print(request.username)
  print(request.avatar)
  print(request.discriminator)
  print(request.userId)

  rpc.reply(to: request, with: .yes) // or .no or .ignore
}

rpc.connect()
```

### Delegation
```swift
import SwordRPC

class ViewController {
  override func viewDidLoad() {
    let rpc = SwordRPC(appId: "123")
    rpc.delegate = self
    rpc.connect()
  }
}

extension ViewController: SwordRPCDelegate {
  func swordRPCDidConnect(
    _ rpc: SwordRPC
  ) {}

  func swordRPCDidDisconnect(
    _ rpc: SwordRPC,
    code: Int?,
    message msg: String?
  ) {}

  func swordRPCDidReceiveError(
    _ rpc: SwordRPC,
    code: Int,
    message msg: String
  ) {}

  func swordRPCDidJoinGame(
    _ rpc: SwordRPC,
    secret: String
  ) {}

  func swordRPCDidSpectateGame(
    _ rpc: SwordRPC,
    secret: String
  ) {}

  func swordRPCDidReceiveJoinRequest(
    _ rpc: SwordRPC,
    request: JoinRequest,
    secret: String
  ) {}
}
```

## Links
Join the [API Channel](https://discord.gg/99a3xNk) to ask questions!
