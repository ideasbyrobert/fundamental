extension MacAccessibilitySemantics
{
    var exposesValue: Bool
    {
        switch self
        {
        case .body,
             .title,
             .section,
             .code,
             .listText,
             .listMarker,
             .caption,
             .headerCellText,
             .bodyCellText:
            true
        case .listItem,
             .table,
             .headerRow,
             .bodyRow,
             .headerCell,
             .bodyCell:
            false
        }
    }

    var value: String?
    {
        switch self
        {
        case let .body(value),
             let .title(value),
             let .section(_, value),
             let .code(value),
             let .listText(_, value),
             let .caption(value),
             let .headerCellText(value),
             let .bodyCellText(value):
            value
        case let .listMarker(item):
            item.label
        case .listItem,
             .table,
             .headerRow,
             .bodyRow,
             .headerCell,
             .bodyCell:
            nil
        }
    }
}
