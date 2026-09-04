import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    @Test("foreign and poisoned indexed inputs refuse atomically")
    func refusal() throws
    {
        let value = try product([
            longParagraph("First"),
            longParagraph("Second")
        ], width: 150)
        let selected = try #require(value.index.extents.last)
        let selection = try #require(value.index.selection(
            expectedLineage: value.index.lineage,
            extents: [selected]
        ))
        let other = try product([
            longParagraph("First"),
            longParagraph("Second")
        ], width: 150, generation: 12)
        let layout = NativeTextKit2Layout()
        #expect(try layout.materialize(
            indexed: other.indexed,
            selection: selection,
            capacity: try generousCapacity()
        ) == nil)
        try expectReconstructedGeometryRefusal()
        try expectPoisonedFontRefusal()
        try expectExactIndexedPairing()
    }
}
