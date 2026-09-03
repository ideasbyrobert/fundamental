import Foundation
import Testing

@Suite("The raster target boundary")
struct RasterArchitectureTests
{
    @Test("production depends only on viewport")
    func dependency() throws
    {
        let package = try String(
            contentsOf: root.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let expected = """
        .target(
                    name: "FundamentalRaster",
                    dependencies: ["FundamentalViewport"]
                )
        """
        #expect(package.contains(expected))
        let source = try productionSource()
        for forbidden in [
            "import FundamentalLayout",
            "import FundamentalProjection",
            "import FundamentalDocument",
            "import AppKit",
            "import CoreText",
            "import Metal",
            "LayoutSnapshot",
            "ViewportSnapshot?"
        ]
        {
            #expect(!source.contains(forbidden))
        }
    }

    @Test("the mark vocabulary invents no absent or provider case")
    func exactVocabulary() throws
    {
        let source = try productionSource()
        for forbidden in [
            "case none",
            "case unknown",
            "case unsupported",
            "case fallback",
            "case other",
            "case clear",
            "case stroke",
            "case image"
        ]
        {
            #expect(!source.contains(forbidden))
        }
    }

    private var root: URL
    {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func productionSource() throws -> String
    {
        let directory = root.appendingPathComponent(
            "Sources/FundamentalRaster"
        )
        return try FileManager.default.contentsOfDirectory(
            atPath: directory.path
        ).sorted().map
        {
            try String(
                contentsOf: directory.appendingPathComponent($0),
                encoding: .utf8
            )
        }.joined()
    }
}
