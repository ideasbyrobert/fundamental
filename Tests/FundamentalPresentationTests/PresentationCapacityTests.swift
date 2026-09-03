import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation
@testable import FundamentalRaster

@Suite("Presentation capacity and refusal")
struct PresentationCapacityTests
{
    @MainActor
    @Test("a stale raster lineage refuses the complete attempt")
    func staleRasterLineageRefuses() throws
    {
        let raster = try makeRaster()
        let other = try PresentationFixture.rasterWithDarkAppearance(raster)
        let request = PresentationRequest(
            expectedRasterLineage: try #require(
                PresentationComposer().rasterLineage(of: other)
            ),
            generation: 19,
            specification: try PresentationFixture.specification(raster),
            intent: .document
        )
        #expect(PresentationComposer().present(
            raster,
            request: request
        ) == nil)
    }

    @MainActor
    @Test("a plane extending left of the document refuses atomically")
    func negativePlaneRefuses() throws
    {
        let raster = try makeRaster()
        let poisoned = try PresentationFixture.rasterWithNegativePlane(raster)
        #expect(PresentationComposer().present(
            poisoned,
            request: try PresentationFixture.request(poisoned)
        ) == nil)
    }

    @MainActor
    func makeRaster() throws -> RasterSnapshot
    {
        try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([
                    .paragraph(SemanticParagraph(runs: [
                        PresentationFixture.run("Bounded")
                    ]))
                ])
            )
        )
    }
}
