// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "APNGImageSerialization",
    platforms: [
        .iOS(.v9),
        .watchOS(.v3),
    ],
    products: [
        .library(
            name: "APNGImageSerialization",
            targets: ["APNGImageSerialization"]
        ),
    ],
    targets: [
        .target(
            name: "APNGImageSerialization",
            path: "APNGImageSerialization/Classes",
            publicHeadersPath: ".",
            linkerSettings: [
                .linkedFramework("ImageIO"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("CoreServices"),
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
