// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ui-image-hash",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .target(
            name: "UIImageHash",
            dependencies: [],
            path: "Sources",
            exclude: [],
            sources: ["UIImageHash"],
            resources: [.process("Resources")],
            swiftSettings: [
                .define("APPLY_APPKIT")
            ],
            linkerSettings: [
                .linkedFramework("AppKit")
            ]),
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
    ]
)
