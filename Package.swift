// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWWebSocket",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(name: "WWWebSocket", targets: ["WWWebSocket"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "WWWebSocket", resources: [.copy("Privacy")]),
    ]
)
