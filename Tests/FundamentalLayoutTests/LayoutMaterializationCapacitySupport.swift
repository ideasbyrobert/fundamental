import Testing

@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    func capacity(
        matching value: LayoutMaterializationUsage,
        lowering index: Int? = nil
    ) throws -> LayoutMaterializationCapacity
    {
        var values = [
            value.reconstructedBlocks,
            value.reconstructedFragments,
            value.materializedFragments,
            value.glyphs,
            value.caretStops,
            value.sourceSlices,
            value.decorations,
            value.fontVariations,
            value.residentUTF16Units
        ]
        if let index
        {
            values[index] -= 1
        }
        return try #require(LayoutMaterializationCapacity(
            reconstructedBlocks: values[0],
            reconstructedFragments: values[1],
            materializedFragments: values[2],
            glyphs: values[3],
            caretStops: values[4],
            sourceSlices: values[5],
            decorations: values[6],
            fontVariations: values[7],
            residentUTF16Units: values[8]
        ))
    }

    func expectPositiveCapacityChannels(
        _ value: LayoutMaterializationUsage
    )
    {
        #expect(value.reconstructedBlocks > 0)
        #expect(value.reconstructedFragments > 0)
        #expect(value.materializedFragments > 0)
        #expect(value.glyphs > 0)
        #expect(value.caretStops > 0)
        #expect(value.sourceSlices > 0)
        #expect(value.decorations > 0)
        #expect(value.fontVariations > 0)
        #expect(value.residentUTF16Units > 0)
    }
}
