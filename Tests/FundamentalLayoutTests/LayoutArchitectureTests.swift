import Foundation
import Testing

@Suite("The layout target boundary")
struct LayoutArchitectureTests
{
    @Test("production depends only on projection")
    func dependency() throws
    {
        let package = try String(
            contentsOf: root.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let expected = """
        .target(
                    name: "FundamentalLayout",
                    dependencies: ["FundamentalProjection"]
                )
        """
        #expect(package.contains(expected))
        let source = try productionSource()
        for forbidden in [
            "FundamentalDocument",
            "FundamentalViewport",
            "FundamentalRaster",
            "FundamentalPresentation",
            "NSTextView",
            "NSGridView",
            "NSWindow",
            "MTL"
        ]
        {
            #expect(!source.contains(forbidden))
        }
    }

    @Test("snapshot values contain no native objects")
    func providerNeutralValues() throws
    {
        let directory = root.appendingPathComponent(
            "Sources/FundamentalLayout"
        )
        let names = try FileManager.default.contentsOfDirectory(
            atPath: directory.path
        ).filter
        {
            $0.hasPrefix("Layout") && $0.hasSuffix(".swift")
        }
        let source = try names.map
        {
            try String(
                contentsOf: directory.appendingPathComponent($0),
                encoding: .utf8
            )
        }.joined()
        for forbidden in [
            "import AppKit",
            "import CoreText",
            "CGPoint",
            "CGRect",
            "CGGlyph",
            "NSFont",
            "CTFont"
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
            "Sources/FundamentalLayout"
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
