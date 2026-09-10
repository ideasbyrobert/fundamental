import FundamentalViewport

extension ViewportRasterizer
{
    static func admits(
        _ run: ResidentLayoutGlyphRun,
        targetBounds: RasterRectangle, budget: inout RasterAdmissionBudget
    ) -> Bool
    {
        let (glyphCount, glyphOverflow) = run.remainingGlyphs.count
            .addingReportingOverflow(1)
        guard !glyphOverflow,
              budget.consumeMarks(1),
              budget.consumeGlyphs(glyphCount),
              budget.consumeFont(
                  postScriptName: run.font.postScriptName,
                  uniqueName: run.font.uniqueName,
                  versionName: run.font.versionName,
                  variationCount: run.font.variations.count
              ),
              Self.admits(run.sourceSlices, budget: &budget)
        else
        {
            return false
        }
        for glyphIndex in 0 ..< glyphCount
        {
            let glyph = glyphIndex == 0
                ? run.firstGlyph
                : run.remainingGlyphs[glyphIndex - 1]
            guard Self.admits(
                glyph.sourceSlices,
                budget: &budget
            )
            else
            {
                return false
            }
        }
        for decoration in run.decorations
        {
            guard let bounds = rectangle(
                x: decoration.frame.minX,
                y: decoration.frame.minY,
                width: decoration.frame.size.width,
                height: decoration.frame.size.height
            )
            else
            {
                return false
            }
            if bounds.intersection(targetBounds) != nil,
               (!budget.consumeFill()
                   || !Self.admits(
                       decoration.sourceSlices,
                       budget: &budget
                   ))
            {
                return false
            }
        }
        return true
    }
}
