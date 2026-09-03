import AppKit
import FundamentalPresentation

enum MacAccessibilitySemantics
{
    case body(String)
    case title(String)
    case section(level: Int, value: String)
    case code(String)
    case caption(String)
    case table
    case headerRow
    case bodyRow
    case headerCell(PresentedTableCellGeometry)
    case bodyCell(PresentedTableCellGeometry)
    case headerCellText(String)
    case bodyCellText(String)

    var role: NSAccessibility.Role
    {
        switch self
        {
        case .body,
             .code,
             .caption,
             .headerCellText,
             .bodyCellText:
            .staticText
        case .title,
             .section:
            .headingRole
        case .table:
            .table
        case .headerRow,
             .bodyRow:
            .row
        case .headerCell,
             .bodyCell:
            .cell
        }
    }

    var exposesValue: Bool
    {
        switch self
        {
        case .body,
             .title,
             .section,
             .code,
             .caption,
             .headerCellText,
             .bodyCellText:
            true
        case .table,
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
             let .caption(value),
             let .headerCellText(value),
             let .bodyCellText(value):
            value
        case .table,
             .headerRow,
             .bodyRow,
             .headerCell,
             .bodyCell:
            nil
        }
    }

    var cellGeometry: PresentedTableCellGeometry?
    {
        switch self
        {
        case let .headerCell(value),
             let .bodyCell(value):
            value
        default:
            nil
        }
    }
}
