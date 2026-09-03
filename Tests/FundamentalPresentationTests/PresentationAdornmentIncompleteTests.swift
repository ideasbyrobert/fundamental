import Testing

@testable import FundamentalPresentation

extension PresentationAdornmentTests
{
    @MainActor
    @Test("a missing resident interval refuses a partial selection")
    func missingResidentIntervalRefuses() throws
    {
        let complete = try textRaster(
            String(repeating: "incomplete range ", count: 12),
            width: 90
        )
        let raster = try PresentationFixture.rasterKeepingFirstAndLast(
            complete
        )
        let document = try PresentationFixture.snapshot(raster)
        let lines = PresentationFixture.textResidents(document)
        #expect(lines.count == 2)
        let first = lines[0]
        let last = lines[1]
        let anchor = try PresentationFixture.position(
            first.0,
            line: first.1,
            caret: 0
        )
        let focus = try PresentationFixture.position(
            last.0,
            line: last.1,
            caret: last.1.caretSites.count - 1
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
