extension PresentedResidentContent
{
    package var textLine: PresentedTextLine?
    {
        switch self
        {
        case let .body(line), let .title(line), let .section(_, line),
             let .code(line), let .caption(line),
             let .headerCell(_, _, .line(line)),
             let .bodyCell(_, _, .line(line)):
            line
        case let .list(_, value):
            value.textLine
        case .table, .tableColumn, .headerRow, .bodyRow,
             .headerCell(_, _, .area), .bodyCell(_, _, .area):
            nil
        }
    }

    package var listItem: PresentationListItem?
    {
        if case let .list(item, _) = self
        {
            return item
        }
        return nil
    }

    package var listMarker: PresentationListMarker?
    {
        if case let .list(_, value) = self
        {
            return value.marker
        }
        return nil
    }
}
