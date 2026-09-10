import FundamentalRaster

extension PresentationComposer
{
    static func gridContent(
        role: RasterInteractionRole, content: RasterInteractionContent,
        residentID: PresentationResidentID
    ) -> PresentedResidentContent?
    {
        switch (role, content)
        {
        case (.table, .region):
            return .table
        case let (.caption, .text(value)):
            return textContent(
                value,
                domain: .caption(residentID.blockID)
            ).map(PresentedResidentContent.caption)
        case let (.tableColumn(index), .columnTrack(value)):
            guard let column = tableColumn(value),
                  column.index == index
            else
            {
                return nil
            }
            return .tableColumn(column)
        case let (.headerRow(index), .rowTrack(value)):
            guard let row = tableRow(value),
                  row.index == index
            else
            {
                return nil
            }
            return .headerRow(row)
        case let (.bodyRow(index), .rowTrack(value)):
            guard let row = tableRow(value),
                  row.index == index
            else
            {
                return nil
            }
            return .bodyRow(row)
        case let (.headerCell(row, cell), .cell(value)):
            return cellArea(value, row: row, cell: cell).map
            {
                .headerCell(row: row, cell: cell, content: .area($0))
            }
        case let (.bodyCell(row, cell), .cell(value)):
            return cellArea(value, row: row, cell: cell).map
            {
                .bodyCell(row: row, cell: cell, content: .area($0))
            }
        case let (.headerCell(row, cell), .text(value)):
            return cellLine(
                value,
                blockID: residentID.blockID,
                row: row,
                cell: cell
            ).map
            {
                .headerCell(row: row, cell: cell, content: .line($0))
            }
        case let (.bodyCell(row, cell), .text(value)):
            return cellLine(
                value,
                blockID: residentID.blockID,
                row: row,
                cell: cell
            ).map
            {
                .bodyCell(row: row, cell: cell, content: .line($0))
            }
        default:
            return nil
        }
    }
}
