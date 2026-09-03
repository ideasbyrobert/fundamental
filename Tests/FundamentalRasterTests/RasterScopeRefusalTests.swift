import Testing

@testable import FundamentalDocument
@testable import FundamentalRaster

extension RasterScopeTests
{
    @MainActor
    @Test("scope payloads are bounded before publication")
    func scopeCapacity() throws
    {
        let destination = try #require(SemanticLinkDestination(
            String(repeating: "x", count: 4_096)
        ))
        let run = SemanticRun.scoped(SemanticScopedRun(
            text: "A",
            scopes: .link(destination)
        ))
        let block = SemanticBlock.paragraph(SemanticParagraph(
            runs: [run]
        ))
        let layout = try RasterFixture.layout([block], width: 400)
        let viewport = try RasterFixture.viewport(layout)
        let capacities = try #require(RasterCapacities(
            marks: 1_000,
            glyphs: 1_000,
            fills: 1_000,
            sourceSlices: 1_000,
            caretSites: 1_000,
            interactionRegions: 1_000,
            fontVariations: 1_000,
            residentUTF16Units: 1_024,
            pixelArea: 1_000_000
        ))
        let specification = try RasterFixture.specification(
            viewport,
            capacities: capacities
        )
        let request = RasterRequest(
            expectedViewportLineage: viewport.lineage,
            generation: 32,
            specification: specification
        )
        #expect(ViewportRasterizer().rasterize(
            viewport,
            request: request
        ) == nil)
    }

    @MainActor
    @Test("scoped input succeeds at its exact retained capacity")
    func exactScopedCapacity() throws
    {
        let destination = try #require(SemanticLinkDestination(
            "https://capacity.test"
        ))
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            .scoped(SemanticScopedRun(
                text: "Scoped",
                traits: [.underline],
                scopes: .link(destination)
            ))
        ]))
        let viewport = try RasterFixture.viewport(
            RasterFixture.layout([block], width: 400)
        )
        let generous = try RasterFixture.snapshot(viewport)
        let count = RasterCounts(generous)
        let capacities = try #require(RasterCapacities(
            marks: count.marks,
            glyphs: count.glyphs,
            fills: count.fills,
            sourceSlices: count.sourceSlices,
            caretSites: count.caretSites,
            interactionRegions: count.interactionRegions,
            fontVariations: count.fontVariations,
            residentUTF16Units: count.residentUTF16Units,
            pixelArea: count.pixelArea
        ))
        let exact = try RasterFixture.snapshot(
            viewport,
            capacities: capacities
        )
        #expect(exact.marks == generous.marks)
        #expect(exact.interactionMap == generous.interactionMap)
    }
}
