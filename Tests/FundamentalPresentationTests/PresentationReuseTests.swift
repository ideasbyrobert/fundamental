import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

@Suite("Presentation storage reuse")
struct PresentationReuseTests
{
    @MainActor
    @Test("adornment changes reuse the complete stable document")
    func adornmentsReuseDocumentStorage() throws
    {
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([
                    .paragraph(SemanticParagraph(runs: [
                        PresentationFixture.run("Reuse me")
                    ]))
                ])
            )
        )
        let initial = try PresentationFixture.snapshot(raster)
        let text = try #require(
            PresentationFixture.textResidents(initial).first
        )
        let position = try PresentationFixture.position(
            text.0,
            line: text.1,
            caret: 1
        )
        let caret = try #require(PresentationComposer().present(
            raster,
            request: PresentationFixture.request(
                raster,
                intent: .caret(position),
                generation: 20
            ),
            reusing: initial
        ))
        #expect(initial.presentedDocument.storage
            === caret.presentedDocument.storage)
        #expect(initial.presentedDocument == initial.presentedDocument)
        #expect(initial.presentedDocument != caret.presentedDocument)
    }

    @MainActor
    @Test("equal stable residents reuse their individual storage")
    func residentsReuseStorage() throws
    {
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([
                    .paragraph(SemanticParagraph(runs: [
                        PresentationFixture.run("First")
                    ])),
                    .paragraph(SemanticParagraph(runs: [
                        PresentationFixture.run("Second")
                    ]))
                ])
            )
        )
        let first = try PresentationFixture.snapshot(raster)
        let second = try #require(PresentationComposer().present(
            raster,
            request: PresentationFixture.request(raster, generation: 20),
            reusing: first
        ))
        let old = first.presentedDocument.residents.all
        let new = second.presentedDocument.residents.all
        #expect(zip(old, new).allSatisfy
        {
            $0.storage === $1.storage
        })
        #expect(first.presentedDocument.storage
            === second.presentedDocument.storage)
    }
}
