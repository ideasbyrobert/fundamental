import Testing

@testable import FundamentalPresentation

extension MacReaderListPixelFixture
{
    static func surface(
        _ value: SummitPresentationSurface, scale: Double, y: Double
    ) throws -> SummitPresentationSurface
    {
        try #require(SummitPresentationSurface(
            readableMeasure: value.readableMeasure, visibleOriginY: y,
            visibleHeight: 120, overscanExtent: 0,
            maximumResidentCount: value.maximumResidentCount,
            backingScale: scale, appearance: value.appearance,
            colorSpace: value.colorSpace, palette: value.palette,
            adornmentPalette: value.adornmentPalette,
            caretWidth: value.caretWidth,
            maximumSelectionFragmentCount: value.maximumSelectionFragmentCount
        ))
    }
}
