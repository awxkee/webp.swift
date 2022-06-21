// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "webp",
    platforms: [
        .macOS(.v10_10), .iOS(.v13)
    ],
    products: [
        .library(
            name: "webp",
            targets: ["webp", "webpbridge"]),
    ],
    dependencies: [
        .package(url: "https://github.com/awxkee/libwebp-ios.git", branch: "master")
    ],
    targets: [
        .target(
            name: "webp",
            dependencies: [.target(name: "webpbridge")],
            swiftSettings: [
                .unsafeFlags(["-suppress-warnings"]),
            ]),
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
