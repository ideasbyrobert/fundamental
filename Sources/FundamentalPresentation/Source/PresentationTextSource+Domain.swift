extension PresentationTextSource
{
    package var domain: PresentationTextDomain
    {
        switch self
        {
        case let .block(blockID, _, _):
            .block(blockID)
        case let .caption(blockID, _, _):
            .caption(blockID)
        case let .cell(blockID, row, cell, _, _):
            .cell(blockID: blockID, row: row, cell: cell)
        }
    }

    package var sourceRange: Range<Int>
    {
        switch self
        {
        case let .block(_, _, range):
            range
        case let .caption(_, _, range):
            range
        case let .cell(_, _, _, _, range):
            range
        }
    }
}
