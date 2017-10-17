// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "PromiseK",
    targets: [
        .target(name: "PromiseK", dependencies: []),
        .testTarget(name: "PromiseKTests", dependencies: ["PromiseK"]),
    ]
)
