import FundamentalRaster

extension PresentationComposer
{
    static func glyphSource(
        _ value: RasterGlyphSource
    ) -> PresentationGlyphSource?
    {
        switch value
        {
        case let .text(slices):
            return sourceSlices(slices).map(PresentationGlyphSource.text)
        case let .listMarker(marker):
            return listMarkerSource(marker)
                .map(PresentationGlyphSource.listMarker)
        }
    }

    static func validGlyphSource(_ value: RasterGlyphBatch) -> Bool
    {
        switch value.source
        {
        case .text:
            return true
        case let .listMarker(source):
            return source.residentID == value.residentID
                && value.glyphs.allSatisfy { $0.sourceSlices.isEmpty }
        }
    }
}
