import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

extension PresentationReuseTests
{
    @MainActor
    @Test("changed mark order prevents stable storage reuse")
    func markOrderPreventsReuse() throws
    {
        let original = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([
                    .paragraph(SemanticParagraph(runs: [
                        PresentationFixture.run("A👩🏽‍💻B")
                    ]))
                ], width: 300)
            )
        )
        #expect(original.marks.count > 1)
        let changed = PresentationFixture.rasterReversingMarks(original)
        let first = try PresentationFixture.snapshot(original)
        let second = try #require(PresentationComposer().present(
            changed,
            request: PresentationFixture.request(
                changed,
                generation: 20
            ),
            reusing: first
        ))
        #expect(second.presentedDocument.marks
            == Array(first.presentedDocument.marks.reversed()))
        #expect(first.presentedDocument.storage
            !== second.presentedDocument.storage)
        #expect(first.presentedDocument.residents.first.storage
            !== second.presentedDocument.residents.first.storage)
    }
}
