import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout
@testable import FundamentalProjection

@Suite("Exact native table source lineage")
struct LayoutExactTableSourceTests
{
    @MainActor
    @Test("caption and cell lines retain exact leaf identities")
    func tableSource() throws
    {
        let block = SemanticBlock.table(
            try LayoutFixture.table(captioned: true)
        )
        let snapshot = try NativeTextKit2Layout().layout(
            LayoutFixture.projection([block]),
            request: LayoutFixture.request(width: 360)
        )
        let grid = try #require(snapshot.grids.first)
        let blockID = LayoutFixture.blockID(0)
        let caption = try #require(grid.captionLines.first)
        #expect(caption.sourceSlices.first?.source == .caption(
            blockID: blockID,
            run: 0,
            range: ProjectedUTF16Range(0 ..< 3)
        ))
        #expect(caption.sourceSlices.first?.range == 0 ..< 3)
        #expect(caption.caretStops.map(\.sourcePoint) == [
            .caption(blockID: blockID, utf16Offset: 0),
            .caption(blockID: blockID, utf16Offset: 1),
            .caption(blockID: blockID, utf16Offset: 3)
        ])
        let body = try #require(grid.cellLines.first
        {
            $0.sourceRow == 1 && $0.sourceCell == 0
        }.map(\.line))
        #expect(body.sourceSlices.first?.source == .cell(
            blockID: blockID,
            row: 1,
            cell: 0,
            run: 0,
            range: ProjectedUTF16Range(0 ..< 3)
        ))
        #expect(body.sourceSlices.first?.range == 0 ..< 3)
        #expect(body.caretStops.map(\.sourcePoint) == [
            .cell(blockID: blockID, row: 1, cell: 0, utf16Offset: 0),
            .cell(blockID: blockID, row: 1, cell: 0, utf16Offset: 1),
            .cell(blockID: blockID, row: 1, cell: 0, utf16Offset: 3)
        ])
        let shifted = try #require(grid.cellLines.first
        {
            $0.sourceRow == 2 && $0.sourceCell == 0
        }.map(\.line))
        #expect(shifted.sourceSlices.first?.source == .cell(
            blockID: blockID,
            row: 2,
            cell: 0,
            run: 0,
            range: ProjectedUTF16Range(0 ..< 5)
        ))
        #expect(shifted.firstCaretStop.sourcePoint == .cell(
            blockID: blockID,
            row: 2,
            cell: 0,
            utf16Offset: 0
        ))
    }
}
