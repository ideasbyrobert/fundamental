import FundamentalPresentation

extension MacAccessibilitySemantics
{
    var listItem: PresentationListItem?
    {
        switch self
        {
        case let .listItem(item), let .listText(item, _),
             let .listMarker(item):
            item
        default:
            nil
        }
    }
}
