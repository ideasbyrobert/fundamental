import Foundation
import Testing

@Suite("The layout target boundary")
struct LayoutArchitectureTests
{
    @Test("production depends on projection and native wrapping")
    func dependency() throws
    {
        let package = try String(
            contentsOf: root.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let expected = ".target(name: \"FundamentalLayout\",\n"
            + "                dependencies: [projection, nativeWrapping])"
        #expect(package.contains(
            "let projection: Target.Dependency = \"FundamentalProjection\""
        ))
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
        let source = try LayoutArchitectureSources(directory: directory).text
        {
            $0.hasPrefix("Layout")
        }
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
        return try LayoutArchitectureSources(directory: directory).text()
    }
}
