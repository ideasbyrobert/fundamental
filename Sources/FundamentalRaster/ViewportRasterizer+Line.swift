import FundamentalViewport

extension ViewportRasterizer
{
    static func append(
        _ line: ResidentLayoutLine,
        residentID: RasterResidentID, residence: RasterResidence,
        role: RasterInteractionRole, frame: RasterRectangle,
        targetBounds: RasterRectangle,
        specification: RasterSpecificationIdentity,
        accumulator: inout RasterAccumulator
    ) -> Bool
    {
        let marker = line.marker.flatMap
        {
            listMarker($0, residentID: residentID, role: role)
        }
        let expectsMarker = role.listPosition != nil
            && residentID.fragmentOrdinal == 0
        guard (line.marker == nil || marker != nil),
              (marker != nil) == expectsMarker,
              let geometry = RasterLineGeometry(
                  line: line, frame: frame, target: targetBounds,
                  scale: specification.backingScale
              ),
              let carets = caretSites(line), let firstCaret = carets.first
        else
        {
            return false
        }
        if let native = line.marker, let marker
        {
            for run in native.glyphRuns
            {
                guard append(
                    run, source: .listMarker(marker.source),
                    residentID: residentID, geometry: geometry,
                    targetBounds: targetBounds, specification: specification,
                    accumulator: &accumulator
                )
                else
                {
                    return false
                }
            }
        }
        for run in line.glyphRuns
        {
            guard append(
                run, source: .text(sourceSlices(run.sourceSlices)),
                residentID: residentID, geometry: geometry,
                targetBounds: targetBounds, specification: specification,
                accumulator: &accumulator
            )
            else
            {
                return false
            }
        }
        let text = RasterInteractionText(
            text: line.text, defaultFont: font(line.defaultFont),
            lineBounds: geometry.bounds, baseline: geometry.baseline,
            marker: marker, sourceSlices: sourceSlices(line.sourceSlices),
            firstCaretSite: firstCaret,
            remainingCaretSites: Array(carets.dropFirst())
        )
        return accumulator.append(RasterInteractionRegion(
            residentID: residentID, residence: residence, role: role,
            frame: frame, content: .text(text)
        ))
    }
}
