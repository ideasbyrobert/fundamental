import Testing

@testable import FundamentalPresentation

extension PresentationAdornmentTests
{
    @MainActor
    @Test("wrapped selection copies every exact line fragment")
    func wrappedSelection() throws
    {
        let raster = try textRaster(
            "One two three four five six seven eight nine ten.",
            width: 90
        )
        let document = try PresentationFixture.snapshot(raster)
        let lines = PresentationFixture.textResidents(document)
        #expect(lines.count > 1)
        let first = try #require(lines.first)
        let last = try #require(lines.last)
        let lower = try PresentationFixture.position(
            first.0,
            line: first.1,
            caret: 0
        )
        let upper = try PresentationFixture.position(
            last.0,
            line: last.1,
            caret: last.1.caretSites.count - 1
        )
        let adornment = try selection(
            raster,
            anchor: lower,
            focus: upper
        )
        #expect(adornment.fragments.count == lines.count)
        #expect(adornment.fragments.map(\.text).joined()
            == adornment.text)
        #expect(adornment.sourceSlices.map(\.text).joined()
            == adornment.text)
        #expect(adornment.fragments.allSatisfy
        {
            $0.logicalBounds.size.width > 0
        })
    }

    @MainActor
    @Test("selection capacity refuses rather than truncating")
    func selectionCapacity() throws
    {
        let raster = try textRaster(
            "One two three four five six seven eight nine ten.",
            width: 90
        )
        let document = try PresentationFixture.snapshot(raster)
        let lines = PresentationFixture.textResidents(document)
        let first = try #require(lines.first)
        let last = try #require(lines.last)
        let lower = try PresentationFixture.position(
            first.0,
            line: first.1,
            caret: 0
        )
        let upper = try PresentationFixture.position(
            last.0,
            line: last.1,
            caret: last.1.caretSites.count - 1
        )
        let exact = try selection(
            raster,
            anchor: lower,
            focus: upper,
            capacity: lines.count
        )
        #expect(exact.fragments.count == lines.count)
        let value = try #require(PresentationTextSelection(
            anchor: lower,
            focus: upper
        ))
        let refused = PresentationComposer().present(
            raster,
            request: try PresentationFixture.request(
                raster,
                intent: .selection(value),
                selectionCapacity: lines.count - 1
            )
        )
        #expect(refused == nil)
    }
}
