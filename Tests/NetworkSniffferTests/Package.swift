// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NetworkSnifferPackage",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "NetworkSnifferPackage",
            targets: ["NetworkSnifferPackage"])
    ],
    swiftLanguageVersions: [.v5],
    dependencies: [],
    targets: [
        .target(
            name: "NetworkSnifferPackage",
            dependencies: [],
            path: "Sources/NetworkSnifferPackage"
        ),
        .testTarget(
            name: "NetworkSnifferPackageTests",
            dependencies: ["NetworkSnifferPackage"],
            path: "Tests/NetworkSnifferPackageTests"
        )
    ]
)
