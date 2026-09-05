// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "Fundamental",
    platforms: [.macOS(.v26)],
    products: [
        .executable(
            name: "FundamentalApplication",
            targets: ["FundamentalApplication"]
        ),
        .executable(name: "lint", targets: ["lint"])
    ],
    targets: [
        .target(name: "FundamentalDocument"),
        .target(
            name: "FundamentalWritingWitness",
            dependencies: ["FundamentalDocument"]
        ),
        .target(
            name: "FundamentalProjection",
            dependencies: ["FundamentalDocument"]
        ),
        .target(
            name: "FundamentalLayout",
            dependencies: ["FundamentalProjection"]
        ),
        .target(
            name: "FundamentalViewport",
            dependencies: ["FundamentalLayout"]
        ),
        .target(
            name: "FundamentalRaster",
            dependencies: ["FundamentalViewport"]
        ),
        .target(
            name: "FundamentalPresentation",
            dependencies: ["FundamentalRaster"]
        ),
        .target(
            name: "FundamentalMacOracle",
            dependencies: ["FundamentalPresentation"]
        ),
        .executableTarget(
            name: "FundamentalApplication",
            dependencies: ["FundamentalMacOracle"]
        ),
        .executableTarget(name: "lint"),
        .testTarget(
            name: "FundamentalDocumentTests",
            dependencies: ["FundamentalDocument"]
        ),
        .testTarget(
            name: "FundamentalWritingWitnessTests",
            dependencies: [
                "FundamentalDocument",
                "FundamentalWritingWitness"
            ]
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
        .testTarget(
            name: "FundamentalViewportTests",
            dependencies: [
                "FundamentalDocument",
                "FundamentalLayout",
                "FundamentalProjection",
                "FundamentalViewport"
            ]
        ),
        .testTarget(
            name: "FundamentalRasterTests",
            dependencies: [
                "FundamentalDocument",
                "FundamentalLayout",
                "FundamentalProjection",
                "FundamentalRaster",
                "FundamentalViewport"
            ]
        ),
        .testTarget(
            name: "FundamentalPresentationTests",
            dependencies: [
                "FundamentalDocument",
                "FundamentalLayout",
                "FundamentalPresentation",
                "FundamentalProjection",
                "FundamentalRaster",
                "FundamentalViewport"
            ]
        ),
        .testTarget(
            name: "FundamentalMacOracleTests",
            dependencies: [
                "FundamentalMacOracle",
                "FundamentalPresentation"
            ]
        ),
        .testTarget(name: "lintTests", dependencies: ["lint"])
    ]
)
