// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "NetworkSnifffer",
    // 1. IMPORTANT: Define the minimum platform version.
    // iOS 14 is safe for modern SwiftUI. Use .v15 if you need newer features.
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
        // This target looks for code in 'Sources/NetworkSnifffer'
        .target(
            name: "NetworkSnifffer",
            dependencies: []
        ),
        .testTarget(
            name: "NetworkSniffferTests",
            dependencies: ["NetworkSnifffer"]
        ),
    ]
)
