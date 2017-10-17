// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "PromiseK",
    products: [
        .library(name: "PromiseK", targets: ["PromiseK"]),
    ],
    targets: [
        .target(name: "PromiseK", dependencies: []),
        .testTarget(name: "PromiseKTests", dependencies: ["PromiseK"]),
    ]
)
