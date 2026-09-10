import FundamentalViewport

extension ViewportRasterizer
{
    static func listMarker(
        _ marker: ResidentLayoutListMarker,
        residentID: RasterResidentID, role: RasterInteractionRole
    ) -> RasterListMarker?
    {
        guard marker.source.block.blockID == residentID.blockID,
              marker.source.block.ordinal == residentID.blockOrdinal,
              Self.role(.prose(marker.source.role)) == role,
              let source = RasterListMarkerSource(
                  residentID: residentID, role: role
              ),
              let baseline = RasterPoint(
                  x: marker.baseline.x, y: marker.baseline.y
              ),
              let ink = rectangle(
                  x: marker.inkBounds.minX, y: marker.inkBounds.minY,
                  width: marker.inkBounds.size.width,
                  height: marker.inkBounds.size.height
              )
        else
        {
            return nil
        }
        for run in marker.glyphRuns
        {
            guard run.sourceSlices.isEmpty, run.decorations.isEmpty,
                  run.glyphs.allSatisfy({ $0.sourceSlices.isEmpty })
            else
            {
                return nil
            }
        }
        return RasterListMarker(
            source: source, baseline: baseline,
            advance: marker.advance, inkBounds: ink
        )
    }
}
