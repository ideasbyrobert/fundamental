package enum RasterGlyphSource: Equatable, Sendable
{
    case text([RasterSourceSlice])
    case listMarker(RasterListMarkerSource)

    package var sourceSlices: [RasterSourceSlice]
    {
        switch self
        {
        case let .text(slices):
            slices
        case .listMarker:
            []
        }
    }
}
