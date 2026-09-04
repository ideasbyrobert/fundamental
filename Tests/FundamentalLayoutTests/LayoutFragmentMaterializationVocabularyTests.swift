import Testing

@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    @Test("capacity admits positive bounds and truthful zero rich limits")
    func capacityVocabulary() throws
    {
        let value = try #require(LayoutMaterializationCapacity(
            reconstructedBlocks: 1,
            reconstructedFragments: 1,
            materializedFragments: 1,
            glyphs: 0,
            caretStops: 0,
            sourceSlices: 0,
            decorations: 0,
            fontVariations: 0,
            residentUTF16Units: 0
        ))
        #expect(value.glyphs == 0)
        #expect(value.residentUTF16Units == 0)
        requireSendable(value)
        for index in 0 ..< 3
        {
            var required = [1, 1, 1]
            required[index] = 0
            #expect(LayoutMaterializationCapacity(
                reconstructedBlocks: required[0],
                reconstructedFragments: required[1],
                materializedFragments: required[2],
                glyphs: 0,
                caretStops: 0,
                sourceSlices: 0,
                decorations: 0,
                fontVariations: 0,
                residentUTF16Units: 0
            ) == nil)
        }
        for index in 0 ..< 6
        {
            var rich = [0, 0, 0, 0, 0, 0]
            rich[index] = -1
            #expect(LayoutMaterializationCapacity(
                reconstructedBlocks: 1,
                reconstructedFragments: 1,
                materializedFragments: 1,
                glyphs: rich[0],
                caretStops: rich[1],
                sourceSlices: rich[2],
                decorations: rich[3],
                fontVariations: rich[4],
                residentUTF16Units: rich[5]
            ) == nil)
        }
        #expect(LayoutMaterializationAccumulator.adding(
            Int.max,
            1,
            limit: Int.max
        ) == nil)
        #expect(LayoutMaterializationAccumulator.adding(
            0,
            -1,
            limit: 1
        ) == nil)
        #expect(LayoutMaterializationAccumulator.adding(
            1,
            1,
            limit: 2
        ) == 2)
        let product = try product([try emptyTable()])
        let full = try diagnostics(
            product,
            extents: product.index.extents
        )
        #expect(full.usage.glyphs == 0)
        #expect(full.usage.caretStops == 0)
        #expect(full.usage.sourceSlices == 0)
        #expect(full.usage.decorations == 0)
        let exact = try capacity(matching: full.usage)
        let admitted = try diagnostics(
            product,
            extents: product.index.extents,
            capacity: exact
        )
        #expect(admitted == full)
    }
}
