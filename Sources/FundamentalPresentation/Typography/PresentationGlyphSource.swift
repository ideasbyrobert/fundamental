package enum PresentationGlyphSource: Equatable, Sendable
{
    case text([PresentationSourceSlice])
    case listMarker(PresentationListMarkerSource)

    package var sourceSlices: [PresentationSourceSlice]
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
