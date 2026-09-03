import Testing

@testable import FundamentalPresentation

extension PresentationAdornmentTests
{
    @MainActor
    @Test("a native trailing-space caret survives typographic line bounds")
    func trailingSpaceCaret() throws
    {
        let raster = try textRaster(
            "One two three four five six seven eight nine ten.",
            width: 90
        )
        let document = try PresentationFixture.snapshot(raster)
        let pair = try #require(
            PresentationFixture.textResidents(document).first
            {
                guard let caret = $0.1.caretSites.last
                else
                {
                    return false
                }
                return caret.position.x > $0.1.lineBounds.maxX
            }
        )
        let position = try PresentationFixture.position(
            pair.0,
            line: pair.1,
            caret: pair.1.caretSites.count - 1
        )
        let snapshot = try PresentationFixture.snapshot(
            raster,
            intent: .caret(position)
        )
        guard case let .caret(_, adornment) = snapshot
        else
        {
            Issue.record("Expected an exact native caret")
            return
        }
        #expect(adornment.sitePosition.x > adornment.lineBounds.maxX)
        #expect(adornment.logicalBounds.minX == adornment.sitePosition.x)
    }
}
