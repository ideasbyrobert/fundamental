import Testing

@testable import FundamentalPresentation

extension PresentationAdornmentTests
{
    @MainActor
    @Test("zero-width caret geometry cannot counterfeit a selection")
    func nondrawableGeometryRefuses() throws
    {
        let original = try textRaster("AB", width: 300)
        let text = try rasterText(original)
        let raster = try PresentationFixture.raster(
            original,
            replacingFirstCaretXs: Array(
                repeating: text.lineBounds.minX,
                count: 3
            )
        )
        try expectSelectionRefusal(raster)
    }
}
