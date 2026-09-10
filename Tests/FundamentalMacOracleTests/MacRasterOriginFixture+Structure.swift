@testable import FundamentalPresentation

extension MacRasterOriginFixture
{
    static var structuralContents: [PresentedResidentContent]
    {
        let area = PresentedTableCellGeometry(
            sourceRow: 0, sourceCell: 0, rowTrack: 0, columnTrack: 0,
            rowSpan: 1, columnSpan: 1, projectedAlignment: .leading,
            resolvedAlignment: .leading
        )
        return [
            .table,
            .tableColumn(PresentedTableColumn(
                index: 0, alignment: .leading, origin: 0, extent: 40
            )),
            .headerRow(PresentedTableRow(index: 0, origin: 0, extent: 20)),
            .bodyRow(PresentedTableRow(index: 0, origin: 0, extent: 20)),
            .headerCell(row: 0, cell: 0, content: .area(area)),
            .bodyCell(row: 0, cell: 0, content: .area(area))
        ]
    }
}
