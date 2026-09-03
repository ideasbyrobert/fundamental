import Testing

@testable import FundamentalDocument
@testable import FundamentalPresentation

extension PresentationAdornmentTests
{
    @MainActor
    @Test("newline-only selection cannot invent drawable geometry")
    func newlineOnlyRefuses() throws
    {
        let block = SemanticBlock.code(.plain(PlainSemanticCodeBlock(runs: [
            PresentationFixture.run("\n")
        ])))
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([block], width: 300)
            )
        )
        let snapshot = try PresentationFixture.snapshot(raster)
        let pair = try #require(
            PresentationFixture.textResidents(snapshot).first
            {
                $0.1.text == "\n" && $0.1.caretSites.count == 2
            }
        )
        let anchor = try PresentationFixture.position(
            pair.0,
            line: pair.1,
            caret: 0
        )
        let focus = try PresentationFixture.position(
            pair.0,
            line: pair.1,
            caret: 1
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
