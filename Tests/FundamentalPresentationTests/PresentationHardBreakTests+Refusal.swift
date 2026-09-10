import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationHardBreakTests
{
    @Test("outlying selection edges refuse before resident publication")
    func outsideResident() throws
    {
        let helpers = PresentationAdornmentTests()
        let original = try helpers.textRaster("\n", width: 300)
        let document = try PresentationFixture.snapshot(original)
        for edges in [(-1.0, 300.0), (0.0, 301.0), (301.0, 0.0)]
        {
            let extent = try #require(RasterSelectionExtent(
                leading: edges.0, trailing: edges.1
            ))
            let raster = try PresentationFixture.raster(
                original, replacingFirstCaretXs: [0, 0],
                selectionExtent: extent
            )
            #expect(PresentationComposer().present(
                raster, request: try PresentationFixture.request(raster),
                reusing: document
            ) == nil)
        }
    }

    @Test("outlying break carets cannot extend feedback beyond the container")
    func outsideCaret() throws
    {
        let helpers = PresentationAdornmentTests()
        let original = try helpers.textRaster("\n", width: 300)
        let endpoints = try helpers.endpointPositions(original)
        let selection = try #require(PresentationTextSelection(
            anchor: endpoints.0, focus: endpoints.1
        ))
        for x in [-1.0, 301.0]
        {
            let raster = try PresentationFixture.raster(
                original, replacingFirstCaretXs: [x, x]
            )
            #expect(PresentationComposer().present(
                raster, request: try PresentationFixture.request(
                    raster, intent: .selection(selection)
                )
            ) == nil)
        }
    }
}
