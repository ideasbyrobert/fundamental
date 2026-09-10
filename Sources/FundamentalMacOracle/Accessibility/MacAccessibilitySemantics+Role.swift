import AppKit

extension MacAccessibilitySemantics
{
    var role: NSAccessibility.Role
    {
        switch self
        {
        case .body,
             .code,
             .listText,
             .caption,
             .headerCellText,
             .bodyCellText:
            .staticText
        case .title,
             .section:
            .headingRole
        case .listItem:
            .group
        case .listMarker:
            .listMarkerRole
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
}
