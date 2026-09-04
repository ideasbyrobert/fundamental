struct LayoutMaterializationAccumulator
{
    let capacity: LayoutMaterializationCapacity
    private(set) var reconstructedBlocks: Int
    private(set) var reconstructedFragments: Int
    private(set) var materializedFragments: Int
    private(set) var glyphs = 0
    private(set) var caretStops = 0
    private(set) var sourceSlices = 0
    private(set) var decorations = 0
    private(set) var fontVariations = 0
    private(set) var residentUTF16Units = 0

    init?(
        capacity: LayoutMaterializationCapacity,
        reconstructedBlocks: Int,
        reconstructedFragments: Int,
        materializedFragments: Int
    )
    {
        guard reconstructedBlocks > 0,
              reconstructedBlocks <= capacity.reconstructedBlocks,
              reconstructedFragments > 0,
              reconstructedFragments <= capacity.reconstructedFragments,
              materializedFragments > 0,
              materializedFragments <= capacity.materializedFragments
        else
        {
            return nil
        }
        self.capacity = capacity
        self.reconstructedBlocks = reconstructedBlocks
        self.reconstructedFragments = reconstructedFragments
        self.materializedFragments = materializedFragments
    }

    var usage: LayoutMaterializationUsage?
    {
        LayoutMaterializationUsage(
            reconstructedBlocks: reconstructedBlocks,
            reconstructedFragments: reconstructedFragments,
            materializedFragments: materializedFragments,
            glyphs: glyphs,
            caretStops: caretStops,
            sourceSlices: sourceSlices,
            decorations: decorations,
            fontVariations: fontVariations,
            residentUTF16Units: residentUTF16Units
        )
    }

    mutating func consumeGlyphs(_ count: Int) -> Bool
    {
        guard let value = Self.adding(
            glyphs,
            count,
            limit: capacity.glyphs
        )
        else
        {
            return false
        }
        glyphs = value
        return true
    }

    mutating func consumeCaretStops(_ count: Int) -> Bool
    {
        guard let value = Self.adding(
            caretStops,
            count,
            limit: capacity.caretStops
        )
        else
        {
            return false
        }
        caretStops = value
        return true
    }

    mutating func consumeDecoration() -> Bool
    {
        guard let value = Self.adding(
            decorations,
            1,
            limit: capacity.decorations
        )
        else
        {
            return false
        }
        decorations = value
        return true
    }

    mutating func consumeSourceSlice() -> Bool
    {
        guard let value = Self.adding(
            sourceSlices,
            1,
            limit: capacity.sourceSlices
        )
        else
        {
            return false
        }
        sourceSlices = value
        return true
    }

    mutating func consumeFontVariations(_ count: Int) -> Bool
    {
        guard let value = Self.adding(
            fontVariations,
            count,
            limit: capacity.fontVariations
        )
        else
        {
            return false
        }
        fontVariations = value
        return true
    }

    mutating func consumeUTF16Units(_ count: Int) -> Bool
    {
        guard let value = Self.adding(
            residentUTF16Units,
            count,
            limit: capacity.residentUTF16Units
        )
        else
        {
            return false
        }
        residentUTF16Units = value
        return true
    }

    static func adding(
        _ value: Int,
        _ count: Int,
        limit: Int
    ) -> Int?
    {
        let result = value.addingReportingOverflow(count)
        guard !result.overflow,
              count >= 0,
              result.partialValue <= limit
        else
        {
            return nil
        }
        return result.partialValue
    }
}
