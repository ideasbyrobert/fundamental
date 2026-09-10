import FundamentalPresentation

extension MacAccessibilitySemantics
{
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
