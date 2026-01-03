// swift-tools-version: 5.9
//import PackageDescription
//
//let package = Package(
//    name: "NetworkSnifffer",
//    // 1. IMPORTANT: Define the minimum platform version.
//    // iOS 14 is safe for modern SwiftUI. Use .v15 if you need newer features.
//    platforms: [
//        .iOS(.v15)
//    ],
//    products: [
//        .library(
//            name: "NetworkSnifffer",
//            type: .dynamic,
//            targets: ["NetworkSnifffer"]
//        ),
//    ],
//    targets: [
//        // This target looks for code in 'Sources/NetworkSnifffer'
//        .target(
//            name: "NetworkSnifffer",
//            dependencies: []
//        ),
//        .testTarget(
//            name: "NetworkSniffferTests",
//            dependencies: ["NetworkSnifffer"]
//        ),
//    ]
//)

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
            targets: ["NetworkSnifffer"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "NetworkSnifffer",
            url: "https://github.com/PrayagSrinivas/NetworkSnifffer/releases/download/1.0.0/NetworkSnifffer.xcframework.zip",
            
            // 2. PASTE YOUR CHECKSUM HERE 👇
            checksum: "b53c161602c1d98a53772b41b9659332505daa619f555fc974fe5836ff0d6214"
        )
    ]
)
