import Foundation
import Testing

@Suite("The viewport target boundary")
struct ViewportArchitectureTests
{
    @Test("production depends only on layout")
    func dependency() throws
    {
        let package = try String(
            contentsOf: root.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let expected = """
        .target(
                    name: "FundamentalViewport",
                    dependencies: ["FundamentalLayout"]
                )
        """
        #expect(package.contains(expected))
        let source = try productionSource()
        for forbidden in [
            "FundamentalDocument",
            "FundamentalProjection",
            "FundamentalRaster",
            "FundamentalPresentation",
            "AppKit",
            "CoreText",
            "Metal"
        ]
        {
            #expect(!source.contains(forbidden))
        }
    }

    @Test("the vocabulary invents no absence or provider cases")
    func exactVocabulary() throws
    {
        let source = try productionSource()
        for forbidden in [
            "case none",
            "case unknown",
            "case unsupported",
            "case fallback",
            "case other",
            "LayoutSnapshot?",
            "let layout: LayoutSnapshot"
        ]
        {
            #expect(!source.contains(forbidden))
        }
    }

    var root: URL
    {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    func productionSource() throws -> String
    {
        let directory = root.appendingPathComponent(
            "Sources/FundamentalViewport"
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
