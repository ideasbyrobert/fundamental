extension RasterAccumulator
{
    mutating func append(_ batch: RasterGlyphBatch) -> Bool
    {
        guard let glyphs = adding(1, batch.remainingGlyphs.count),
              let slices = glyphSourceSliceCount(batch),
              let sourceUTF16 = glyphSourceUTF16Count(batch),
              let fontUTF16 = fontUTF16Count(batch.font),
              let utf16 = adding(sourceUTF16, fontUTF16),
              let nextMarks = adding(marks.count, 1),
              let nextGlyphs = adding(glyphCount, glyphs),
              let nextSlices = adding(sourceSliceCount, slices),
              let nextVariations = adding(
                  fontVariationCount,
                  batch.font.variations.count
              ),
              let nextUTF16 = adding(residentUTF16Count, utf16),
              nextMarks <= capacities.marks,
              nextGlyphs <= capacities.glyphs,
              nextSlices <= capacities.sourceSlices,
              nextVariations <= capacities.fontVariations,
              nextUTF16 <= capacities.residentUTF16Units
        else
        {
            return false
        }
        marks.append(.glyphs(batch))
        glyphCount = nextGlyphs
        sourceSliceCount = nextSlices
        fontVariationCount = nextVariations
        residentUTF16Count = nextUTF16
        return true
    }
}
