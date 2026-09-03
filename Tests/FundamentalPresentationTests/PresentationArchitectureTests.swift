import Foundation
import Testing

@Suite("The presentation target boundary")
struct PresentationArchitectureTests
{
    @Test("production depends only on raster")
    func dependency() throws
    {
        let package = try String(
            contentsOf: root.appendingPathComponent("Package.swift"),
            encoding: .utf8
        )
        let expected = """
        .target(
                    name: "FundamentalPresentation",
                    dependencies: ["FundamentalRaster"]
                )
        """
        #expect(package.contains(expected))
        let source = try productionSource()
        for forbidden in [
            "import FundamentalViewport",
            "import FundamentalLayout",
            "import FundamentalProjection",
            "import FundamentalDocument",
            "import AppKit",
            "import CoreText",
            "import CoreGraphics",
            "import Metal"
        ]
        {
            #expect(!source.contains(forbidden))
        }
    }

    @Test("published values contain no raster or optional adornment")
    func outwardVocabulary() throws
    {
        let source = try valueSource()
        #expect(!source.contains("import FundamentalRaster"))
        #expect(!source.contains(": RasterSnapshot"))
        #expect(!source.contains(": RasterMark"))
        #expect(!source.contains(": RasterLineage"))
        #expect(!source.contains("case none"))
        #expect(!source.contains("case unknown"))
        #expect(!source.contains("case fallback"))
        #expect(!source.contains("let adornment:"))
        #expect(!source.split(separator: "\n").contains
        {
            $0.contains("package let") && $0.contains("?")
        })
    }

}
