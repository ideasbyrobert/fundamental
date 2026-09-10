extension RasterAccumulator
{
    func glyphSourceSliceCount(
        _ batch: RasterGlyphBatch
    ) -> Int?
    {
        var count = batch.sourceSlices.count
        guard let first = sourceSliceCount(
            batch.firstGlyph.sourceSlices,
            startingAt: count
        )
        else
        {
            return nil
        }
        count = first
        for glyph in batch.remainingGlyphs
        {
            guard let next = sourceSliceCount(
                glyph.sourceSlices,
                startingAt: count
            )
            else
            {
                return nil
            }
            count = next
        }
        return count
    }

    func glyphSourceUTF16Count(
        _ batch: RasterGlyphBatch
    ) -> Int?
    {
        guard var count = sourceSliceUTF16Count(batch.sourceSlices)
        else
        {
            return nil
        }
        guard let firstCount = sourceSliceUTF16Count(
            batch.firstGlyph.sourceSlices
        ),
              let first = adding(count, firstCount)
        else
        {
            return nil
        }
        count = first
        for glyph in batch.remainingGlyphs
        {
            guard let glyphCount = sourceSliceUTF16Count(
                glyph.sourceSlices
            ),
                  let next = adding(count, glyphCount)
            else
            {
                return nil
            }
            count = next
        }
        return count
    }
}
