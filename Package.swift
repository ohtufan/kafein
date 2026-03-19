// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Kafein",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "Kafein", targets: ["Kafein"]),
        .library(name: "KafeinCore", targets: ["KafeinCore"]),
    ],
    targets: [
        .executableTarget(
            name: "Kafein",
            dependencies: ["KafeinCore"]
        ),
        .target(
            name: "KafeinCore",
            linkerSettings: [
                .linkedFramework("IOKit"),
                .linkedFramework("Carbon"),
            ]
        ),
        .testTarget(
            name: "KafeinCoreTests",
            dependencies: ["KafeinCore"]
        ),
    ]
)
