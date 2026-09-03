import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

extension PresentationAdornmentTests
{
    @MainActor
    @Test("collapsed selections and missing carets are refused")
    func collapsedAndMissingRefuse() throws
    {
        let raster = try textRaster("Present", width: 300)
        let snapshot = try PresentationFixture.snapshot(raster)
        let text = try #require(
            PresentationFixture.textResidents(snapshot).first
        )
        let position = try PresentationFixture.position(
            text.0,
            line: text.1,
            caret: 0
        )
        #expect(PresentationTextSelection(
            anchor: position,
            focus: position
        ) == nil)
        let missingID = try #require(PresentationResidentID(
            blockID: position.residentID.blockID,
            blockOrdinal: position.residentID.blockOrdinal,
            fragmentOrdinal: 999
        ))
        let missing = PresentationTextPosition(
            residentID: missingID,
            sourcePoint: position.sourcePoint
        )
        #expect(PresentationComposer().present(
            raster,
            request: try PresentationFixture.request(
                raster,
                intent: .caret(missing)
            )
        ) == nil)
    }

    @MainActor
    @Test("selection across source domains is refused")
    func crossDomainRefuses() throws
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
        let snapshot = try PresentationFixture.snapshot(raster)
        let lines = PresentationFixture.textResidents(snapshot)
        let first = lines[0]
        let second = lines[1]
        let anchor = try PresentationFixture.position(
            first.0,
            line: first.1,
            caret: 0
        )
        let focus = try PresentationFixture.position(
            second.0,
            line: second.1,
            caret: second.1.caretSites.count - 1
        )
        let value = try #require(PresentationTextSelection(
            anchor: anchor,
            focus: focus
        ))
        #expect(PresentationComposer().present(
            raster,
            request: try PresentationFixture.request(
                raster,
                intent: .selection(value)
            )
        ) == nil)
    }
}
