// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Fundamental",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "lint", targets: ["lint"])
    ],
    targets: [
        .target(name: "FundamentalDocument"),
        .target(
            name: "FundamentalProjection",
            dependencies: ["FundamentalDocument"]
        ),
        .target(
            name: "FundamentalLayout",
            dependencies: ["FundamentalProjection"]
        ),
        .executableTarget(name: "lint"),
        .testTarget(
            name: "FundamentalDocumentTests",
            dependencies: ["FundamentalDocument"]
        ),
        .testTarget(
            name: "FundamentalProjectionTests",
            dependencies: [
                "FundamentalDocument",
                "FundamentalProjection"
            ]
        ),
        .testTarget(
            name: "FundamentalLayoutTests",
            dependencies: [
                "FundamentalDocument",
                "FundamentalLayout",
                "FundamentalProjection"
            ]
        ),
        .testTarget(name: "lintTests", dependencies: ["lint"])
    ]
)
