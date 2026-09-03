import Testing

@testable import FundamentalPresentation

extension PresentationAdornmentTests
{
    @MainActor
    @Test("wrap-boundary endpoints retain identity without empty fragments")
    func wrapBoundaryEndpoints() throws
    {
        let raster = try textRaster(
            "One two three four five six seven eight nine ten.",
            width: 90
        )
        let document = try PresentationFixture.snapshot(raster)
        let lines = PresentationFixture.textResidents(document)
        let first = lines[0]
        let second = lines[1]
        let boundaryEnd = try PresentationFixture.position(
            first.0,
            line: first.1,
            caret: first.1.caretSites.count - 1
        )
        let insideSecond = try PresentationFixture.position(
            second.0,
            line: second.1,
            caret: 2
        )
        let forward = try selection(
            raster,
            anchor: boundaryEnd,
            focus: insideSecond
        )
        let reverse = try selection(
            raster,
            anchor: insideSecond,
            focus: boundaryEnd
        )
        #expect(forward.anchor == boundaryEnd)
        #expect(reverse.focus == boundaryEnd)
        #expect(forward.fragments == reverse.fragments)
        #expect(forward.fragments.count == 1)
        #expect(forward.firstFragment.residentID == second.0.residentID)
        let insideFirst = try PresentationFixture.position(
            first.0,
            line: first.1,
            caret: first.1.caretSites.count - 2
        )
        let boundaryStart = try PresentationFixture.position(
            second.0,
            line: second.1,
            caret: 0
        )
        let ending = try selection(
            raster,
            anchor: insideFirst,
            focus: boundaryStart
        )
        #expect(ending.focus == boundaryStart)
        #expect(ending.fragments.count == 1)
        #expect(ending.firstFragment.residentID == first.0.residentID)
    }
}
