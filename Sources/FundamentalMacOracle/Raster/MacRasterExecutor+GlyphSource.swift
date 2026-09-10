import FundamentalPresentation

extension MacRasterExecutor
{
    static func sourceText(_ source: PresentationGlyphSource) -> String
    {
        switch source
        {
        case let .text(slices):
            slices.map(\.text).joined()
        case let .listMarker(marker):
            marker.label
        }
    }
}
