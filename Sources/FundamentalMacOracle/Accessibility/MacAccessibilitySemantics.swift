import AppKit
import FundamentalPresentation

enum MacAccessibilitySemantics
{
    case body(String)
    case title(String)
    case section(level: Int, value: String)
    case code(String)
    case listItem(PresentationListItem)
    case listText(PresentationListItem, String)
    case listMarker(PresentationListItem)
    case caption(String)
    case table
    case headerRow
    case bodyRow
    case headerCell(PresentedTableCellGeometry)
    case bodyCell(PresentedTableCellGeometry)
    case headerCellText(String)
    case bodyCellText(String)
}
