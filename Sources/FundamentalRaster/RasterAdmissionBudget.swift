struct RasterAdmissionBudget
{
    let capacities: RasterCapacities
    private var marks = 0
    private var glyphs = 0
    private var fills = 0
    private var sourceSlices = 0
    private var caretSites = 0
    private var interactionRegions = 0
    private var fontVariations = 0
    private var residentUTF16Units = 0

    mutating func consumeMarks(_ count: Int) -> Bool
    {
        guard let next = Self.consumed(
            marks,
            count: count,
            limit: capacities.marks
        )
        else
        {
            return false
        }
        marks = next
        return true
    }

    mutating func consumeGlyphs(_ count: Int) -> Bool
    {
        guard let next = Self.consumed(
            glyphs,
            count: count,
            limit: capacities.glyphs
        )
        else
        {
            return false
        }
        glyphs = next
        return true
    }

    mutating func consumeFills(_ count: Int) -> Bool
    {
        guard let next = Self.consumed(
            fills,
            count: count,
            limit: capacities.fills
        )
        else
        {
            return false
        }
        fills = next
        return true
    }

    mutating func consumeFill() -> Bool
    {
        consumeMarks(1) && consumeFills(1)
    }

    mutating func consumeCaretSites(_ count: Int) -> Bool
    {
        guard let next = Self.consumed(
            caretSites,
            count: count,
            limit: capacities.caretSites
        )
        else
        {
            return false
        }
        caretSites = next
        return true
    }

    mutating func consumeInteractionRegion() -> Bool
    {
        guard let next = Self.consumed(
            interactionRegions,
            count: 1,
            limit: capacities.interactionRegions
        )
        else
        {
            return false
        }
        interactionRegions = next
        return true
    }

    mutating func consumeFont(
        postScriptName: String,
        uniqueName: String,
        versionName: String,
        variationCount: Int
    ) -> Bool
    {
        guard let next = Self.consumed(
            fontVariations,
            count: variationCount,
            limit: capacities.fontVariations
        ),
              consumeText(postScriptName),
              consumeText(uniqueName),
              consumeText(versionName)
        else
        {
            return false
        }
        fontVariations = next
        return true
    }

    mutating func consumeSourceSlice(_ text: String) -> Bool
    {
        guard let next = Self.consumed(
            sourceSlices,
            count: 1,
            limit: capacities.sourceSlices
        )
        else
        {
            return false
        }
        sourceSlices = next
        return consumeText(text)
    }

    mutating func consumeText(_ text: String) -> Bool
    {
        let remaining = capacities.residentUTF16Units
            - residentUTF16Units
        let limit = remaining == Int.max
            ? Int.max
            : remaining + 1
        let count = text.utf16.prefix(limit).count
        guard count <= remaining
        else
        {
            return false
        }
        residentUTF16Units += count
        return true
    }

    private static func consumed(
        _ value: Int,
        count: Int,
        limit: Int
    ) -> Int?
    {
        let (next, overflow) = value.addingReportingOverflow(count)
        guard !overflow,
              count >= 0,
              next <= limit
        else
        {
            return nil
        }
        return next
    }
}
