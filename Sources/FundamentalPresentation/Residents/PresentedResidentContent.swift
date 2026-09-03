package enum PresentedResidentContent: Equatable, Sendable
{
    case body(PresentedTextLine)
    case title(PresentedTextLine)
    case section(PresentationHeadingLevel, PresentedTextLine)
    case code(PresentedTextLine)
    case table
    case caption(PresentedTextLine)
    case tableColumn(PresentedTableColumn)
    case headerRow(PresentedTableRow)
    case bodyRow(PresentedTableRow)
    case headerCell(
        row: Int,
        cell: Int,
        content: PresentedTableCellContent
    )
    case bodyCell(
        row: Int,
        cell: Int,
        content: PresentedTableCellContent
    )
}
