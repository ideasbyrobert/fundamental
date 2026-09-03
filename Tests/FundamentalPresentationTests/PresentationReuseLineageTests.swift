import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

extension PresentationReuseTests
{
    @MainActor
    @Test("a changed document revision fences equal resident storage")
    func revisionPreventsReuse() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(runs: [
            PresentationFixture.run("Revision")
        ]))
        let firstRaster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([block], revision: 7)
            )
        )
        let secondRaster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([block], revision: 8)
            )
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
        #expect(first.presentedDocument.storage
            !== second.presentedDocument.storage)
    }
}
