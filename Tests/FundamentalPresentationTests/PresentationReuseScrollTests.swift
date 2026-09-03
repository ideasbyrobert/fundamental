import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalPresentation

extension PresentationReuseTests
{
    @MainActor
    @Test("scrolling reuses an unchanged overscan resident as visible")
    func scrollingReusesResidentStorage() throws
    {
        let text = String(repeating: "reuse line ", count: 40)
        let layout = try PresentationFixture.layout([
            .paragraph(SemanticParagraph(runs: [
                PresentationFixture.run(text)
            ]))
        ], width: 120)
        let visible = layout.fragments[3]
        let preceding = layout.fragments[2]
        let firstViewport = try PresentationFixture.viewport(
            layout,
            y: visible.frame.minY,
            height: visible.frame.size.height,
            preceding: visible.frame.minY - preceding.frame.minY,
            limit: 2
        )
        let secondViewport = try PresentationFixture.viewport(
            layout,
            y: preceding.frame.minY,
            height: preceding.frame.size.height,
            generation: 14
        )
        let firstRaster = try PresentationFixture.raster(firstViewport)
        let secondRaster = try PresentationFixture.raster(secondViewport)
        let first = try PresentationFixture.snapshot(firstRaster)
        let second = try #require(PresentationComposer().present(
            secondRaster,
            request: PresentationFixture.request(
                secondRaster,
                generation: 20
            ),
            reusing: first
        ))
        let identifier = try #require(PresentationResidentID(
            blockID: preceding.anchor.blockID,
            blockOrdinal: preceding.anchor.blockOrdinal,
            fragmentOrdinal: preceding.anchor.fragmentOrdinal
        ))
        let old = try #require(first.presentedDocument.residents.all.first
        {
            $0.residentID == identifier
        })
        let new = try #require(second.presentedDocument.residents.all.first
        {
            $0.residentID == identifier
        })
        #expect(old.residence == .overscan(.preceding))
        #expect(new.residence == .visible)
        #expect(old.storage === new.storage)
        #expect(first.presentedDocument.storage
            !== second.presentedDocument.storage)
    }
}
