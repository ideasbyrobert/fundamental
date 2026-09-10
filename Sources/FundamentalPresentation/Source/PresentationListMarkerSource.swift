package struct PresentationListMarkerSource: Equatable, Sendable
{
    package let residentID: PresentationResidentID
    package let item: PresentationListItem

    package init?(
        residentID: PresentationResidentID, item: PresentationListItem
    )
    {
        guard residentID.fragmentOrdinal == 0
        else
        {
            return nil
        }
        self.residentID = residentID
        self.item = item
    }

    package var label: String
    {
        item.label
    }
}
