import Foundation

extension PresentationComposer
{
    static func validListResidents(
        _ residents: PresentedResidentCollection
    ) -> Bool
    {
        var items: [UUID: PresentationListItem] = [:]
        var ordinals: [UUID: Int] = [:]
        for resident in residents.all
        {
            guard let item = resident.content.listItem
            else
            {
                continue
            }
            let id = resident.residentID
            if let previous = items[id.blockID]
            {
                guard previous == item,
                      ordinals[id.blockID] == id.blockOrdinal
                else
                {
                    return false
                }
            }
            items[id.blockID] = item
            ordinals[id.blockID] = id.blockOrdinal
        }
        return residents.all.allSatisfy
        {
            guard let item = items[$0.residentID.blockID]
            else
            {
                return true
            }
            return $0.content.listItem == item
                && ordinals[$0.residentID.blockID]
                    == $0.residentID.blockOrdinal
        }
    }
}
