// swift-tools-version:5.0
// minimum version of swift required

import PackageDescription

let package = Package(
  name: "SwordRPC",
  products: [
    .library(name: "SwordRPC", targets: ["SwordRPC"])
  ],
  dependencies: [
    .package(url: "https://github.com/Kitura/BlueSocket.git", from: "2.0.4")
  ],
  targets: [
    .target(
      name: "SwordRPC",
      dependencies: [.product(name: "Socket", package: "BlueSocket")]
    )
  ]
)
