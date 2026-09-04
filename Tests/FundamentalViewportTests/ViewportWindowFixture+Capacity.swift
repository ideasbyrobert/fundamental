import Testing

@testable import FundamentalLayout

extension ViewportWindowFixture
{
    static func indexCapacity(
        blocks: Int = 10_000,
        extents: Int = 1_000_000
    ) throws -> LayoutExtentIndexCapacity
    {
        try #require(LayoutExtentIndexCapacity(
            maximumBlockCount: blocks,
            maximumExtentCount: extents,
            maximumResolvedFontCount: 4_096,
            maximumTableRowCount: 100_000,
            maximumTableCellCount: 100_000
        ))
    }

    static func materializationCapacity(
        richLimit: Int = 2_000_000
    ) throws -> LayoutMaterializationCapacity
    {
        try #require(LayoutMaterializationCapacity(
            reconstructedBlocks: 10_000,
            reconstructedFragments: 1_000_000,
            materializedFragments: 1_000_000,
            glyphs: richLimit,
            caretStops: richLimit,
            sourceSlices: richLimit,
            decorations: richLimit,
            fontVariations: richLimit,
            residentUTF16Units: richLimit
        ))
    }
}
