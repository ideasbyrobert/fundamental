extension RasterAccumulator
{
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
}
