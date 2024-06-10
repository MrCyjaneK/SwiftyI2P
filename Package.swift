// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftyI2P",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "SwiftyI2P",
            targets: ["SwiftyI2P"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftyI2P",
            dependencies: ["i2pbridge"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ],
            linkerSettings: [
                .linkedLibrary("z"),
            ]
        ),
        .target(
            name: "i2pbridge",
            dependencies: ["i2pdcpp"]
        ),
        .testTarget(
            name: "SwiftyI2PTests",
            dependencies: ["SwiftyI2P"]
        ),
        .binaryTarget(name: "i2pdcpp", path: "i2pdcpp/install/i2pdcpp.xcframework"),
    ],
    cxxLanguageStandard: .cxx11
)
