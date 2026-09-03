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
        .testTarget(name: "lintTests", dependencies: ["lint"])
    ]
)
