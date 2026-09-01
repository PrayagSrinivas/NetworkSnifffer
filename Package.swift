// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NetworkSnifffer",
    // Minimum platform version. iOS 15 is required for the SwiftUI debugger UI.
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "NetworkSnifffer",
            targets: ["NetworkSnifffer"]
        ),
    ],
    targets: [
        // Sources live under Sources/{Core,Manager,Views}, not Sources/NetworkSnifffer,
        // so the target path has to be set explicitly or SwiftPM cannot build the graph.
        .target(
            name: "NetworkSnifffer",
            path: "Sources"
        ),
        .testTarget(
            name: "NetworkSniffferTests",
            dependencies: ["NetworkSnifffer"],
            path: "Tests/NetworkSniffferTests"
        ),
    ]
)
