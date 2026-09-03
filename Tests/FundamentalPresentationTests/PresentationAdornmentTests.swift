import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

@Suite("Presentation adornments")
struct PresentationAdornmentTests
{
    @MainActor
    @Test("a caret uses the exact admitted site and line bounds")
    func caretUsesExactEvidence() throws
    {
        let raster = try textRaster("A👩🏽‍💻B", width: 300)
        let document = try PresentationFixture.snapshot(raster)
        let text = try #require(
            PresentationFixture.textResidents(document).first
        )
        let position = try PresentationFixture.position(
            text.0,
            line: text.1,
            caret: 2
        )
        let snapshot = try #require(PresentationComposer().present(
            raster,
            request: PresentationFixture.request(
                raster,
                intent: .caret(position)
            ),
            reusing: document
        ))
        guard case let .caret(presented, adornment) = snapshot
        else
        {
            Issue.record("expected a caret snapshot")
            return
        }
        let expected = text.1.caretSites[2]
        #expect(adornment.position == position)
        #expect(adornment.sitePosition == expected.position)
        #expect(adornment.lineBounds == text.1.lineBounds)
        #expect(adornment.logicalBounds.minX == expected.position.x)
        #expect(adornment.logicalBounds.size.height
            == text.1.lineBounds.size.height)
        #expect(presented.storage === document.presentedDocument.storage)
    }

    @MainActor
    @Test("forward and reverse selections preserve endpoint identity")
    func forwardAndReverseSelection() throws
    {
        let raster = try textRaster("Alpha beta", width: 300)
        let document = try PresentationFixture.snapshot(raster)
        let text = try #require(
            PresentationFixture.textResidents(document).first
        )
        let lower = try PresentationFixture.position(
            text.0,
            line: text.1,
            caret: 0
        )
        let upper = try PresentationFixture.position(
            text.0,
            line: text.1,
            caret: 5
        )
        let forward = try selection(raster, anchor: lower, focus: upper)
        let reverse = try selection(raster, anchor: upper, focus: lower)
        #expect(forward.text == "Alpha")
        #expect(reverse.text == "Alpha")
        #expect(forward.anchor == lower)
        #expect(forward.focus == upper)
        #expect(reverse.anchor == upper)
        #expect(reverse.focus == lower)
        #expect(forward.fragments == reverse.fragments)
    }
}
