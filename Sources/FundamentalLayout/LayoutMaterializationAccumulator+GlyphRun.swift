extension LayoutMaterializationAccumulator
{
    mutating func consume(_ run: LayoutGlyphRun) -> Bool
    {
        let glyphCount = run.remainingGlyphs.count
            .addingReportingOverflow(1)
        guard !glyphCount.overflow,
              consumeGlyphs(glyphCount.partialValue),
              consume(run.font),
              consume(run.sourceSlices),
              consume(run.firstGlyph.sourceSlices)
        else
        {
            return false
        }
        for glyph in run.remainingGlyphs
        {
            guard consume(glyph.sourceSlices)
            else
            {
                return false
            }
        }
        for decoration in run.decorations
        {
            guard consumeDecoration(), consume(decoration.sourceSlices)
            else
            {
                return false
            }
        }
        return true
    }
}
