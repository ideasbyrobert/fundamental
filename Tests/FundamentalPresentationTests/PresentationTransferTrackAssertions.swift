import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func expectColumn(
        _ source: RasterTableColumnGeometry,
        role: RasterInteractionRole,
        equals result: PresentedResidentContent
    )
    {
        guard case let .tableColumn(index) = role,
              case let .tableColumn(column) = result
        else
        {
            Issue.record("Expected a table column")
            return
        }
        #expect(index == source.index)
        #expect(column.index == source.index)
        #expect(alignmentSignature(source.alignment)
            == alignmentSignature(column.alignment))
        #expect(column.origin == source.origin)
        #expect(column.extent == source.extent)
    }

    func expectRow(
        _ source: RasterTableRowGeometry,
        role: RasterInteractionRole,
        equals result: PresentedResidentContent
    )
    {
        let resultRow: PresentedTableRow
        switch (role, result)
        {
        case let (.headerRow(index), .headerRow(row)),
             let (.bodyRow(index), .bodyRow(row)):
            #expect(index == source.index)
            resultRow = row
        default:
            Issue.record("Expected a matching table row")
            return
        }
        #expect(resultRow.index == source.index)
        #expect(resultRow.origin == source.origin)
        #expect(resultRow.extent == source.extent)
    }
}
