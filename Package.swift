// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SonyFX30Controller",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
    ],
    targets: [
        .executableTarget(
            name: "SonyFX30Controller",
            path: "Sources/SonyFX30Controller"
        )
    ]
)
