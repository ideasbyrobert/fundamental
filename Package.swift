// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Fundamental",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "lint", targets: ["lint"])
    ],
    targets: [
        .target(name: "FundamentalDocument"),
        .executableTarget(name: "lint"),
        .testTarget(
            name: "FundamentalDocumentTests",
            dependencies: ["FundamentalDocument"]
        ),
        .testTarget(name: "lintTests", dependencies: ["lint"])
    ]
)
