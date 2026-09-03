import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func expectCell(
        _ source: RasterTableCellGeometry,
        role: RasterInteractionRole,
        equals result: PresentedResidentContent
    )
    {
        let area: PresentedTableCellGeometry
        switch (role, result)
        {
        case let (
            .headerCell(row, cell),
            .headerCell(resultRow, resultCell, .area(value))
        ),
             let (
                 .bodyCell(row, cell),
                 .bodyCell(resultRow, resultCell, .area(value))
             ):
            #expect(row == resultRow)
            #expect(cell == resultCell)
            area = value
        default:
            Issue.record("Expected a matching table cell")
            return
        }
        #expect(area.sourceRow == source.sourceRow)
        #expect(area.sourceCell == source.sourceCell)
        #expect(area.rowTrack == source.rowTrack)
        #expect(area.columnTrack == source.columnTrack)
        #expect(area.rowSpan == source.rowSpan)
        #expect(area.columnSpan == source.columnSpan)
        #expect(alignmentSignature(source.projectedAlignment)
            == alignmentSignature(area.projectedAlignment))
        #expect(alignmentSignature(source.resolvedAlignment)
            == alignmentSignature(area.resolvedAlignment))
    }

    func alignmentSignature(_ value: RasterTableAlignment) -> Int
    {
        switch value
        {
        case .unspecified: 0
        case .leading: 1
        case .center: 2
        case .trailing: 3
        }
    }

    func alignmentSignature(_ value: PresentationTableAlignment) -> Int
    {
        switch value
        {
        case .unspecified: 0
        case .leading: 1
        case .center: 2
        case .trailing: 3
        }
    }
}
