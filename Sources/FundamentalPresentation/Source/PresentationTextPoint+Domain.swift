extension PresentationTextPoint
{
    package var domain: PresentationTextDomain
    {
        switch self
        {
        case let .block(blockID, _):
            .block(blockID)
        case let .caption(blockID, _):
            .caption(blockID)
        case let .cell(blockID, row, cell, _):
            .cell(blockID: blockID, row: row, cell: cell)
        }
    }

    package var utf16Offset: Int
    {
        switch self
        {
        case let .block(_, offset):
            offset
        case let .caption(_, offset):
            offset
        case let .cell(_, _, _, offset):
            offset
        }
    }
}
