import FundamentalRaster

extension PresentationComposer
{
    static func listMarkerSource(
        _ value: RasterListMarkerSource
    ) -> PresentationListMarkerSource?
    {
        guard let owner = residentID(value.residentID),
              let item = listItem(value.role)
        else
        {
            return nil
        }
        return PresentationListMarkerSource(residentID: owner, item: item)
    }

    static func listMarker(
        _ value: RasterListMarker
    ) -> PresentationListMarker?
    {
        guard let source = listMarkerSource(value.source),
              let baseline = point(value.baseline),
              let ink = rectangle(value.inkBounds)
        else
        {
            return nil
        }
        return PresentationListMarker(
            source: source, baseline: baseline,
            advance: value.advance, inkBounds: ink
        )
    }
}
