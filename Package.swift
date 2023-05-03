// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWWebSocket",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "WWWebSocket", targets: ["WWWebSocket"]),
    ],
    dependencies: [
        .package(url: "https://github.com/William-Weng/WWPrint.git", from: "1.0.1"),
    ],
    targets: [
        .target(name: "WWWebSocket", dependencies: []),
    ]
)
