// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NetworkSnifffer",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "NetworkSnifffer",
            // Note: 'type: .dynamic' is REMOVED here. This is correct for binary distribution.
            targets: ["NetworkSnifffer"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "NetworkSnifffer",
            url: "https://github.com/PrayagSrinivas/NetworkSnifffer/releases/download/1.0.2/NetworkSnifffer.xcframework.zip",
            checksum: "611b0a33de05ad76b974c4653126969946ba58a2ecdb6f2f33308d45e4d27788"
        )
    ]
)
