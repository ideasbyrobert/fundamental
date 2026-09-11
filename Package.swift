// swift-tools-version: 6.4

import PackageDescription

let document: Target.Dependency = "FundamentalDocument"
let storage: Target.Dependency = "FundamentalStorage"
let wrapping: Target.Dependency = "FundamentalWrapping"
let nativeWrapping: Target.Dependency = "FundamentalNativeWrapping"
let paragraph: Target.Dependency = "FundamentalParagraph"
let nativeParagraph: Target.Dependency = "FundamentalNativeParagraph"
let writing: Target.Dependency = "FundamentalWritingWitness"
let projection: Target.Dependency = "FundamentalProjection"
let layout: Target.Dependency = "FundamentalLayout"
let viewport: Target.Dependency = "FundamentalViewport"
let raster: Target.Dependency = "FundamentalRaster"
let presentation: Target.Dependency = "FundamentalPresentation"
let oracle: Target.Dependency = "FundamentalMacOracle"

let package = Package(
    name: "Fundamental",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "Fundamental",
                    targets: ["FundamentalWritingWitness"]),
        .executable(name: "FundamentalApplication",
                    targets: ["FundamentalApplication"]),
        .executable(name: "lint", targets: ["lint"]),
        .executable(name: "bundle", targets: ["bundle"])
    ],
    targets: [
        .target(name: "FundamentalDocument"),
        .target(name: "FundamentalWrapping"),
        .target(name: "FundamentalNativeWrapping", dependencies: [wrapping]),
        .target(name: "FundamentalParagraph",
                dependencies: [document, wrapping],
                resources: [.copy("Resources/Hyphenation")]),
        .target(name: "FundamentalNativeParagraph",
                dependencies: [document, paragraph, wrapping, nativeWrapping]),
        .target(name: "FundamentalStorage", dependencies: [document]),
        .executableTarget(name: "FundamentalWritingWitness",
            dependencies: [document, storage]
        ),
        .target(name: "FundamentalProjection", dependencies: [document]),
        .target(name: "FundamentalLayout",
                dependencies: [projection, nativeWrapping]),
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
        .executableTarget(name: "FundamentalApplication",
            dependencies: ["FundamentalMacOracle"]),
        .executableTarget(name: "lint", path: "Tools/Lint"),
        .executableTarget(name: "bundle", path: "Tools/Bundle"),
        .testTarget(name: "FundamentalDocumentTests", dependencies: [document]),
        .testTarget(name: "FundamentalWrappingTests", dependencies: [wrapping]),
        .testTarget(name: "FundamentalNativeWrappingTests",
                    dependencies: [wrapping, nativeWrapping]),
        .testTarget(name: "FundamentalParagraphTests",
                    dependencies: [
                        document, wrapping, paragraph, nativeParagraph
                    ]),
        .testTarget(
            name: "FundamentalStorageTests",
            dependencies: [document, storage]
        ),
        .testTarget(
            name: "FundamentalWritingWitnessTests",
            dependencies: [document, storage, writing, oracle, presentation]
        ),
        .testTarget(
            name: "FundamentalProjectionTests",
            dependencies: [document, projection]
        ),
        .testTarget(
            name: "FundamentalLayoutTests",
            dependencies: [document, layout, projection, nativeWrapping]
        ),
        .testTarget(
            name: "FundamentalViewportTests",
            dependencies: [document, layout, projection, viewport]
        ),
        .testTarget(
            name: "FundamentalRasterTests",
            dependencies: [document, layout, projection, raster, viewport]
        ),
        .testTarget(
            name: "FundamentalPresentationTests",
            dependencies: [
                document, layout, presentation, projection, raster, viewport
            ]
        ),
        .testTarget(
            name: "FundamentalMacOracleTests",
            dependencies: [document, oracle, presentation]
        ),
        .testTarget(name: "lintTests", dependencies: ["lint"]),
        .testTarget(name: "bundleTests", dependencies: ["bundle"])
    ]
)
