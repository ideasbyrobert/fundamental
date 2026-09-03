import Testing

@testable import FundamentalPresentation

extension PresentationAdornmentTests
{
    @MainActor
    @Test("pure descending caret geometry admits an exact RTL selection")
    func descendingSelection() throws
    {
        let original = try textRaster("AB", width: 300)
        let text = try rasterText(original)
        let midpoint = (text.lineBounds.minX + text.lineBounds.maxX) / 2
        let raster = try PresentationFixture.raster(
            original,
            replacingFirstCaretXs: [
                text.lineBounds.maxX,
                midpoint,
                text.lineBounds.minX
            ]
        )
        let endpoints = try endpointPositions(raster)
        let adornment = try selection(
            raster,
            anchor: endpoints.0,
            focus: endpoints.1
        )
        #expect(adornment.text == "AB")
        #expect(adornment.firstFragment.logicalBounds.minX
            == text.lineBounds.minX)
        #expect(adornment.firstFragment.logicalBounds.maxX
            == text.lineBounds.maxX)
    }

    @MainActor
    @Test("mixed bidi-like caret geometry is refused")
    func mixedGeometryRefuses() throws
    {
        let original = try textRaster("ABC", width: 300)
        let text = try rasterText(original)
        let midpoint = (text.lineBounds.minX + text.lineBounds.maxX) / 2
        let raster = try PresentationFixture.raster(
            original,
            replacingFirstCaretXs: [
                text.lineBounds.minX,
                text.lineBounds.maxX,
                midpoint,
                text.lineBounds.maxX
            ]
        )
        try expectSelectionRefusal(raster)
    }
}
