enum LayoutFragmentExtentContent: Equatable, Sendable
{
    case line(LayoutLineRole)
    case tableRegion
    case tableCaptionLine
    case tableColumnTrack
    case tableRowTrack
    case tableCell
    case tableCellLine
    case tableRule

    var isTableContent: Bool
    {
        switch self
        {
        case .line:
            false
        case .tableRegion, .tableCaptionLine, .tableColumnTrack,
             .tableRowTrack, .tableCell, .tableCellLine, .tableRule:
            true
        }
    }
}
