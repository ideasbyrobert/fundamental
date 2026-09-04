import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    @Test("every admitted table form equals its eager rich fragments")
    func tableForms() throws
    {
        let blocks: [SemanticBlock] = [
            .table(try LayoutFixture.table(captioned: false)),
            .table(try LayoutFixture.table(captioned: true)),
            try emptyTable(),
            try emptyTable(withRows: true)
        ]
        var contents: [LayoutFragmentExtentContent] = []
        for block in blocks
        {
            let value = try product([block], width: 360)
            let result = try diagnostics(
                value,
                extents: value.index.extents
            )
            try expectExact(
                result,
                product: value,
                extents: value.index.extents
            )
            contents += value.index.extents.map(\.content)
        }
        let expected: [LayoutFragmentExtentContent] = [
            .tableRegion,
            .tableCaptionLine,
            .tableColumnTrack,
            .tableRowTrack,
            .tableCell,
            .tableCellLine,
            .tableRule
        ]
        #expect(expected.allSatisfy(contents.contains))
    }

    @MainActor
    @Test("selected extents reconstruct each selected block once")
    func selectedBlocks() throws
    {
        let value = try product([
            longParagraph("First"),
            .table(try LayoutFixture.table(captioned: true)),
            longParagraph("Third")
        ], width: 150)
        let first = value.index.extents.filter
        {
            $0.anchor.blockOrdinal == 0
        }
        let second = value.index.extents.filter
        {
            $0.anchor.blockOrdinal == 1
        }
        let extents = [
            try #require(first.first),
            try #require(first.last),
            try #require(second.last)
        ]
        let result = try diagnostics(
            value,
            extents: Array(extents.reversed())
        )
        try expectExact(result, product: value, extents: extents)
        #expect(result.usage.reconstructedBlocks == 2)
        #expect(result.usage.materializedFragments == 3)
        #expect(result.materialization.fragments.count == 3)
    }

    @MainActor
    @Test("one nonzero extent charges only its complete source block")
    func sparseWindow() throws
    {
        let value = try product([
            longParagraph("Selected"),
            longParagraph("Unrelated")
        ], width: 130)
        let selectedBlock = value.index.extents.filter
        {
            $0.anchor.blockOrdinal == 0
        }
        let selected = try #require(selectedBlock.dropFirst().first)
        let result = try diagnostics(value, extents: [selected])
        try expectExact(result, product: value, extents: [selected])
        #expect(selected.anchor.fragmentOrdinal > 0)
        #expect(result.usage.reconstructedBlocks == 1)
        #expect(result.usage.reconstructedFragments
            == selectedBlock.count)
        #expect(result.usage.materializedFragments == 1)
    }
}
