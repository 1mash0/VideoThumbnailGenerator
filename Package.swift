// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VideoThumbnailGenerator",
    platforms: [.macOS(.v13)],
    products: [
        .executable(
            name: "vtg",
            targets: [
                "VideoThumbnailGenerator"
            ]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
    ],
    targets: [
        .executableTarget(
            name: "VideoThumbnailGenerator",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
