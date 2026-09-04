import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutBlockMeasurementTests
{
    @MainActor
    @Test("nonzero sources stay local and global font order stays eager")
    func nonzeroSourceAndGlobalFontOrder() throws
    {
        let prose = SemanticBlock.paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct("Following prose")
        ]))
        let projection = try LayoutFixture.projection([
            try emptyTable(),
            prose
        ])
        let request = try LayoutFixture.request(width: 320)
        let layout = NativeTextKit2Layout()
        let tableValue = try layout.measure(
            projection.blocks[0],
            parameters: request.parameters
        )
        let proseValue = try layout.measure(
            projection.blocks[1],
            parameters: request.parameters
        )
        let snapshot = try layout.layout(projection, request: request)
        let table = try #require(tableFacts(tableValue))
        #expect(proseValue.source == projection.blocks[1].source)
        #expect(proseValue.extents.map(\.source)
            == Array(repeating: proseValue.source,
                     count: proseValue.extents.count))
        #expect(proseValue.extents.map(\.anchor.blockOrdinal)
            == Array(repeating: 1, count: proseValue.extents.count))
        #expect(proseValue.extents.map(\.anchor.fragmentOrdinal)
            == Array(proseValue.extents.indices))
        #expect(proseValue.firstExtent.frame.minY == 0)
        #expect(snapshot.fragments.last?.frame.minY != 0)
        #expect(tableValue.contentFonts.isEmpty)
        #expect(snapshot.lineage.specification.resolvedFonts
            == proseValue.contentFonts + [table.structuralFont])
    }
}
