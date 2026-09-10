import FundamentalViewport

extension ViewportRasterizer
{
    static func admits(
        _ line: ResidentLayoutLine,
        residentID: RasterResidentID, role: RasterInteractionRole,
        targetBounds: RasterRectangle, budget: inout RasterAdmissionBudget
    ) -> Bool
    {
        let marker = line.marker.flatMap
        {
            listMarker($0, residentID: residentID, role: role)
        }
        let expectsMarker = role.listPosition != nil
            && residentID.fragmentOrdinal == 0
        let (caretCount, overflow) = line.remainingCaretStops.count
            .addingReportingOverflow(1)
        guard (line.marker == nil || marker != nil),
              (marker != nil) == expectsMarker, !overflow,
              budget.consumeText(line.text),
              budget.consumeCaretSites(caretCount),
              budget.consumeFont(
                  postScriptName: line.defaultFont.postScriptName,
                  uniqueName: line.defaultFont.uniqueName,
                  versionName: line.defaultFont.versionName,
                  variationCount: line.defaultFont.variations.count
              ),
              admits(line.sourceSlices, budget: &budget)
        else
        {
            return false
        }
        if let native = line.marker, let marker
        {
            guard budget.consumeText(marker.source.label)
            else
            {
                return false
            }
            for run in native.glyphRuns
            {
                guard admits(
                    run, targetBounds: targetBounds, budget: &budget
                )
                else
                {
                    return false
                }
            }
        }
        for run in line.glyphRuns
        {
            guard admits(run, targetBounds: targetBounds, budget: &budget)
            else
            {
                return false
            }
        }
        return true
    }
}
