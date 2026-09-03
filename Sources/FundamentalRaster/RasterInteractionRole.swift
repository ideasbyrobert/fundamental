package enum RasterInteractionRole: Equatable, Sendable
{
    case body
    case title
    case section(RasterHeadingLevel)
    case code
    case table
    case caption
    case tableColumn(Int)
    case headerRow(Int)
    case bodyRow(Int)
    case headerCell(row: Int, cell: Int)
    case bodyCell(row: Int, cell: Int)
}
