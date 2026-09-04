import Testing

@testable import FundamentalLayout

struct ExpectedLayoutMaterializationUsage
{
    var reconstructedBlocks: Int
    var reconstructedFragments = 0
    var materializedFragments: Int
    var glyphs = 0
    var caretStops = 0
    var sourceSlices = 0
    var decorations = 0
    var fontVariations = 0
    var residentUTF16Units = 0

    init(
        snapshot: LayoutSnapshot,
        selectedExtents: [LayoutPlacedFragmentExtent]
    )
    {
        let ordinals = Set(selectedExtents.map(\.anchor.blockOrdinal))
        reconstructedBlocks = ordinals.count
        materializedFragments = selectedExtents.count
        let fragments = snapshot.fragments.filter
        {
            ordinals.contains($0.anchor.blockOrdinal)
        }
        reconstructedFragments = fragments.count
        for fragment in fragments
        {
            consume(fragment)
        }
        for grid in snapshot.grids
        where ordinals.contains(grid.source.ordinal)
        {
            consume(grid.structuralFont)
        }
    }

    func admitted() throws -> LayoutMaterializationUsage
    {
        try #require(LayoutMaterializationUsage(
            reconstructedBlocks: reconstructedBlocks,
            reconstructedFragments: reconstructedFragments,
            materializedFragments: materializedFragments,
            glyphs: glyphs,
            caretStops: caretStops,
            sourceSlices: sourceSlices,
            decorations: decorations,
            fontVariations: fontVariations,
            residentUTF16Units: residentUTF16Units
        ))
    }
}
