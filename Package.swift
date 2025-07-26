// swift-tools-version:5.3
// minimum version of swift required

import PackageDescription

let package = Package(
  name: "SwordRPC",
  platforms: [
    .macOS(.v10_15),
  ],
  products: [
    .library(name: "SwordRPC", targets: ["SwordRPC"])
  ],
  dependencies: [
    .package(url: "https://github.com/Kitura/BlueSocket.git", from: "2.0.2")
  ],
  targets: [
    .target(
      name: "SwordRPC",
      dependencies: [.product(name: "Socket", package: "BlueSocket")]
    )
  ]
)
