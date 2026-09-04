import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    func product(
        _ blocks: [SemanticBlock],
        width: Double = 320,
        generation: UInt64 = 11
    ) throws -> LayoutMaterializationTestProduct
    {
        let projection = try LayoutFixture.projection(blocks)
        let request = try LayoutFixture.request(
            width: width,
            generation: generation
        )
        let layout = NativeTextKit2Layout()
        let indexed = try layout.indexedProjection(
            projection,
            request: request,
            capacity: try indexCapacity()
        )
        return LayoutMaterializationTestProduct(
            indexed: indexed,
            request: request,
            eager: try layout.layout(projection, request: request)
        )
    }

    func indexCapacity() throws -> LayoutExtentIndexCapacity
    {
        try #require(LayoutExtentIndexCapacity(
            maximumBlockCount: 1_000,
            maximumExtentCount: 100_000,
            maximumResolvedFontCount: 1_000,
            maximumTableRowCount: 100_000,
            maximumTableCellCount: 100_000
        ))
    }

    func generousCapacity() throws -> LayoutMaterializationCapacity
    {
        try #require(LayoutMaterializationCapacity(
            reconstructedBlocks: 1_000,
            reconstructedFragments: 100_000,
            materializedFragments: 100_000,
            glyphs: 1_000_000,
            caretStops: 1_000_000,
            sourceSlices: 1_000_000,
            decorations: 1_000_000,
            fontVariations: 1_000_000,
            residentUTF16Units: 10_000_000
        ))
    }
}
