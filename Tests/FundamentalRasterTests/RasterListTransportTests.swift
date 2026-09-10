import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalRaster

@Suite("Typed raster list transport", .serialized)
@MainActor
struct RasterListTransportTests
{
    @Test("a canonical list reaches raster with its exact source",
          arguments: SemanticListKind.allCases)
    func canonicalList(kind: SemanticListKind) throws
    {
        let text = "Exact e\u{301} 👩🏽‍💻 Раздел"
        let layout = try RasterFixture.layout([
            .listItem(SemanticListItem(
                kind: kind, runs: [RasterFixture.run(text)]
            ))
        ], width: 400)
        #expect(layout.fragments.contains
        {
            guard case let .lines(fragment) = $0 else { return false }
            return fragment.line.marker != nil
        })
        let viewport = try RasterFixture.viewport(layout)
        let raster = try RasterFixture.snapshot(viewport)
        let texts: [String] = raster.interactionMap.regions.compactMap
        {
            guard case let .text(value) = $0.content else { return nil }
            return value.text
        }
        #expect(texts == [text])
    }
}
