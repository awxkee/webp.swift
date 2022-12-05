// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "webp",
    platforms: [
        .macOS(.v10_10), .iOS(.v13), .macCatalyst(.v14)
    ],
    products: [
        .library(
            name: "webp",
            targets: ["webp", "webpbridge"]),
    ],
    dependencies: [
        .package(url: "https://github.com/awxkee/libwebp-ios.git", "1.0.0"..<"1.1.0")
    ],
    targets: [
        .target(
            name: "webp",
            dependencies: [.target(name: "webpbridge")]),
        .target(name: "webpbridge",
                dependencies: [.product(name: "libwebp", package: "libwebp-ios")],
                path: "Sources/webpbridge",
                publicHeadersPath: "include",
                cSettings: [
                    .headerSearchPath("."),
                ],
                linkerSettings: [.linkedFramework("Accelerate")])
    ]
)
