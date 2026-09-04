import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    @Test("selection requires nonempty exact index truth")
    func selectionTruth() throws
    {
        let value = try product([
            .paragraph(SemanticParagraph(runs: [
                LayoutFixture.direct("Exact indexed truth")
            ]))
        ])
        let extent = value.index.extents[0]
        #expect(value.index.selection(
            expectedLineage: value.index.lineage,
            extents: []
        ) == nil)
        let duplicate = [extent, extent]
        #expect(value.index.selection(
            expectedLineage: value.index.lineage,
            extents: duplicate
        ) == nil)
        let shifted = try #require(LayoutPlacedFragmentExtent(
            localExtent: extent.localExtent,
            documentOriginY: 1
        ))
        #expect(value.index.selection(
            expectedLineage: value.index.lineage,
            extents: [shifted]
        ) == nil)
        let other = try product([
            .paragraph(SemanticParagraph(runs: []))
        ], generation: 12)
        #expect(value.index.selection(
            expectedLineage: other.index.lineage,
            extents: [extent]
        ) == nil)
    }

    @MainActor
    @Test("caller order canonicalizes to exact index paint order")
    func selectionOrder() throws
    {
        let value = try product([
            longParagraph("First"),
            longParagraph("Second")
        ], width: 150)
        let final = try #require(value.index.extents.last)
        let candidates = [
            final,
            value.index.extents[1],
            value.index.extents[0]
        ]
        let selection = try #require(value.index.selection(
            expectedLineage: value.index.lineage,
            extents: candidates
        ))
        let expected = value.index.extents.filter(candidates.contains)
        #expect(selection.extents == expected)
        #expect(selection.lineage == value.index.lineage)
        #expect(selection == selection)
        requireSendable(selection)
    }

    func requireSendable<T: Sendable>(_ value: T)
    {
        _ = value
    }
}
