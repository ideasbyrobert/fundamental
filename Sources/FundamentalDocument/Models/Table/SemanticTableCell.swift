enum SemanticTableCell: Equatable, Sendable
{
    case regular(RegularSemanticTableCell)
    case spanning(SpanningSemanticTableCell)

    var runs: [SemanticRun]
    {
        switch self
        {
        case let .regular(cell):
            cell.runs
        case let .spanning(cell):
            cell.runs
        }
    }

    var alignment: SemanticTableColumnAlignment
    {
        switch self
        {
        case let .regular(cell):
            cell.alignment
        case let .spanning(cell):
            cell.alignment
        }
    }

    var rowCount: Int
    {
        switch self
        {
        case .regular:
            1
        case let .spanning(cell):
            cell.extent.rowCount
        }
    }

    var columnCount: Int
    {
        switch self
        {
        case .regular:
            1
        case let .spanning(cell):
            cell.extent.columnCount
        }
    }

    var plainText: String
    {
        runs.map(\.text).joined()
    }
}
