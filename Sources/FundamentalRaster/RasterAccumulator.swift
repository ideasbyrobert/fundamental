struct RasterAccumulator
{
    let capacities: RasterCapacities
    private(set) var marks: [RasterMark] = []
    private(set) var regions: [RasterInteractionRegion] = []
    private var glyphCount = 0
    private var fillCount = 0
    private var sourceSliceCount = 0
    private var caretSiteCount = 0
    private var fontVariationCount = 0
    private var residentUTF16Count = 0

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

    mutating func append(_ fill: RasterFill) -> Bool
    {
        guard let nextMarks = adding(marks.count, 1),
              let nextFills = adding(fillCount, 1),
              let utf16 = sourceSliceUTF16Count(fill.sourceSlices),
              let nextSlices = adding(
                  sourceSliceCount,
                  fill.sourceSlices.count
              ),
              let nextUTF16 = adding(residentUTF16Count, utf16),
              nextMarks <= capacities.marks,
              nextFills <= capacities.fills,
              nextSlices <= capacities.sourceSlices,
              nextUTF16 <= capacities.residentUTF16Units
        else
        {
            return false
        }
        marks.append(.fill(fill))
        fillCount = nextFills
        sourceSliceCount = nextSlices
        residentUTF16Count = nextUTF16
        return true
    }

    mutating func append(_ region: RasterInteractionRegion) -> Bool
    {
        var slices = 0
        var carets = 0
        var variations = 0
        var utf16 = 0
        switch region.content
        {
        case .region, .columnTrack, .rowTrack, .cell:
            break
        case let .text(text):
            guard let textSlices = interactionSourceSliceCount(text),
                  let caretCount = adding(
                      1,
                      text.remainingCaretSites.count
                  )
            else
            {
                return false
            }
            guard let sourceUTF16 = interactionSourceUTF16Count(text),
                  let textUTF16 = adding(
                      text.text.utf16.count,
                      sourceUTF16
                  ),
                  let fontUTF16 = fontUTF16Count(text.defaultFont),
                  let totalUTF16 = adding(
                      textUTF16,
                      fontUTF16
                  )
            else
            {
                return false
            }
            slices = textSlices
            carets = caretCount
            variations = text.defaultFont.variations.count
            utf16 = totalUTF16
        }
        guard let nextRegions = adding(regions.count, 1),
              let nextSlices = adding(sourceSliceCount, slices),
              let nextCarets = adding(caretSiteCount, carets),
              let nextVariations = adding(
                  fontVariationCount,
                  variations
              ),
              let nextUTF16 = adding(residentUTF16Count, utf16),
              nextRegions <= capacities.interactionRegions,
              nextSlices <= capacities.sourceSlices,
              nextCarets <= capacities.caretSites,
              nextVariations <= capacities.fontVariations,
              nextUTF16 <= capacities.residentUTF16Units
        else
        {
            return false
        }
        regions.append(region)
        sourceSliceCount = nextSlices
        caretSiteCount = nextCarets
        fontVariationCount = nextVariations
        residentUTF16Count = nextUTF16
        return true
    }

    private func glyphSourceSliceCount(
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

    private func interactionSourceSliceCount(
        _ text: RasterInteractionText
    ) -> Int?
    {
        text.sourceSlices.count
    }

    private func glyphSourceUTF16Count(
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

    private func sourceSliceCount(
        _ slices: [RasterSourceSlice],
        startingAt count: Int
    ) -> Int?
    {
        adding(count, slices.count)
    }

    private func interactionSourceUTF16Count(
        _ text: RasterInteractionText
    ) -> Int?
    {
        sourceSliceUTF16Count(text.sourceSlices)
    }

    private func sourceSliceUTF16Count(
        _ slices: [RasterSourceSlice]
    ) -> Int?
    {
        var count = 0
        for slice in slices
        {
            guard let scopeCount = scopeUTF16Count(slice.scope),
                  let textCount = adding(
                      slice.text.utf16.count,
                      scopeCount
                  ),
                  let next = adding(count, textCount)
            else
            {
                return nil
            }
            count = next
        }
        return count
    }

    private func scopeUTF16Count(
        _ scope: RasterRunScope
    ) -> Int?
    {
        switch scope
        {
        case .direct:
            0
        case let .link(destination):
            destination.utf16.count
        case let .language(identifier):
            identifier.utf16.count
        case let .linkAndLanguage(link, language):
            adding(link.utf16.count, language.utf16.count)
        }
    }

    private func fontUTF16Count(
        _ font: RasterFontIdentity
    ) -> Int?
    {
        guard let names = adding(
            font.postScriptName.utf16.count,
            font.uniqueName.utf16.count
        )
        else
        {
            return nil
        }
        return adding(names, font.versionName.utf16.count)
    }

    private func adding(_ first: Int, _ second: Int) -> Int?
    {
        let (value, overflow) = first.addingReportingOverflow(second)
        return overflow ? nil : value
    }
}
