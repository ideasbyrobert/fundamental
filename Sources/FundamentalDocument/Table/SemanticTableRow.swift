enum SemanticTableRow: Equatable, Sendable
{
    case header(HeaderSemanticTableRow)
    case body(BodySemanticTableRow)

    var cells: [SemanticTableCell]
    {
        switch self
        {
        case let .header(row):
            row.cells
        case let .body(row):
            row.cells
        }
    }
}
