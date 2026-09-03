extension PresentationComposer
{
    static func validMarkSources(
        _ marks: [PresentationMark],
        residentID: PresentationResidentID,
        content: PresentedResidentContent
    ) -> Bool
    {
        let slices = marks.flatMap
        {
            markSourceSlices($0)
        }
        switch content
        {
        case .body,
             .title,
             .section,
             .code:
            return slices.allSatisfy
            {
                $0.source.domain == .block(residentID.blockID)
            }
        case .caption:
            return slices.allSatisfy
            {
                $0.source.domain == .caption(residentID.blockID)
            }
        case let .headerCell(row, cell, _),
             let .bodyCell(row, cell, _):
            return slices.allSatisfy
            {
                $0.source.domain == .cell(
                    blockID: residentID.blockID,
                    row: row,
                    cell: cell
                )
            }
        case .table,
             .tableColumn,
             .headerRow,
             .bodyRow:
            return slices.isEmpty
        }
    }

    static func markSourceSlices(
        _ mark: PresentationMark
    ) -> [PresentationSourceSlice]
    {
        switch mark
        {
        case let .glyphs(batch):
            return batch.sourceSlices + batch.glyphs.flatMap
            {
                $0.sourceSlices
            }
        case let .fill(fill):
            return fill.sourceSlices
        }
    }
}
