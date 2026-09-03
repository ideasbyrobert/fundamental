import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

extension PresentationReuseTests
{
    @MainActor
    @Test("scale and profile changes prevent inappropriate reuse")
    func rasterSpecificationPreventsReuse() throws
    {
        let viewport = try PresentationFixture.viewport(
            PresentationFixture.layout([
                .paragraph(SemanticParagraph(runs: [
                    PresentationFixture.run("Raster identity")
                ]))
            ])
        )
        let initialRaster = try PresentationFixture.raster(viewport)
        let initial = try PresentationFixture.snapshot(initialRaster)
        for raster in [
            try PresentationFixture.raster(viewport, scale: 1),
            try PresentationFixture.raster(viewport, profile: [4, 5, 6])
        ]
        {
            let result = try #require(PresentationComposer().present(
                raster,
                request: PresentationFixture.request(
                    raster,
                    generation: 20
                ),
                reusing: initial
            ))
            #expect(initial.presentedDocument.storage
                !== result.presentedDocument.storage)
            #expect(initial.presentedDocument.residents.first.storage
                !== result.presentedDocument.residents.first.storage)
        }
    }

    @MainActor
    @Test("document palette changes fence otherwise equal residents")
    func palettePreventsReuse() throws
    {
        let viewport = try PresentationFixture.viewport(
            PresentationFixture.layout([
                .paragraph(SemanticParagraph(runs: [
                    PresentationFixture.run("Palette")
                ]))
            ])
        )
        let firstRaster = try PresentationFixture.raster(viewport)
        let secondRaster = try PresentationFixture.raster(
            viewport,
            documentBackground: 0.95
        )
        let first = try PresentationFixture.snapshot(firstRaster)
        let second = try #require(PresentationComposer().present(
            secondRaster,
            request: PresentationFixture.request(
                secondRaster,
                generation: 20
            ),
            reusing: first
        ))
        let old = first.presentedDocument.residents.first.storage
        let new = second.presentedDocument.residents.first.storage
        #expect(old == new)
        #expect(old !== new)
    }
}
