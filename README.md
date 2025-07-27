# SwordRPC - A Discord RPC library for Swift

[![Swift Version](https://img.shields.io/badge/Swift-5.3-orange.svg?style=flat-square)](https://swift.org)
[![Tag](https://img.shields.io/github/tag/sjalkote/SwordRPC.svg?style=flat-square&label=release)](https://github.com/sjalkote/SwordRPC/releases)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/sjalkote/SwordRPC/swift.yml?style=flat-square)

This fork provides a more up-to-date and maintained version of the SwordRPC library, which allows you to **integrate Discord Rich Presence into your Swift apps**.
The code has been heavily documented and the package has been updated with new features and fixes, hopefully making it somewhat more enjoyable to use.

I've also added detailed [**documentation here**](https://sjalkote.github.io/SwordRPC/documentation/swordrpc/).

Some of the changes so far include:

- Source updated for Swift 5.0 or higher, support for Swift Package Manager, and updated the Socket dependency.
- **Extensive** documentation with DocC & reformatted source code (**In progress**)
- Timestamp `Double` -> `Int` auto conversion that integrates nicely with any existing usages out of the box.
- Return `Result<Void,SwordRPCError>` in `connect()` to provide explicit `.failure` reasons for additional context (e.g. Discord not detected).
- Make `JoinRequest` properties public so that callers can display information about the users who request to join the activity.
- Fix encoding by using Optionals to skip nil rich presence values instead of sending an empty string.
- Upgraded platform req to macOS `v10_15`
    - Removes usages of `DispatchQueue` in favor of Swift Concurrency's `Task` queues.
- Other random things like `Secrets?` nil to allow buttons, favoring strict types such as `TimeInterval` over `Int`, etc.
- Added support for RPC Buttons (Discord only allows up to 2 buttons)
- uhhh more stuff in progress
- TODO: build DocC documentation and put it on gh pages or smth
- TODO: github swift packages and Actions integration
- TODO: more code improvements and convenience features

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
/// handlerInterval: TimeInterval = 1 (decides how fast to check discord for updates, if needed use floats like 0.5 for 500ms)
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
