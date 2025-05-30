// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WebNike",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "WebNike",
            targets: ["WebNike"]
        ),
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .target(
            name: "WebNike",
            dependencies: [],
            path: "WebNike",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "WebNikeTests",
            dependencies: ["WebNike"]
        ),
    ]
)
