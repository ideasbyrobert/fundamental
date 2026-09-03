import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

extension PresentationReuseTests
{
    @MainActor
    @Test("a changed stable appearance prevents storage reuse")
    func appearancePreventsReuse() throws
    {
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([
                    .paragraph(SemanticParagraph(runs: [
                        PresentationFixture.run("Appearance")
                    ]))
                ])
            )
        )
        let initial = try PresentationFixture.snapshot(raster)
        let altered = try PresentationFixture.rasterWithDarkAppearance(raster)
        let result = try #require(PresentationComposer().present(
            altered,
            request: PresentationFixture.request(altered, generation: 20),
            reusing: initial
        ))
        #expect(initial.presentedDocument.storage
            !== result.presentedDocument.storage)
        #expect(initial.presentedDocument.residents.first.storage
            !== result.presentedDocument.residents.first.storage)
        #expect(initial.presentedDocument.residents.first.storage
            == result.presentedDocument.residents.first.storage)
    }
}
