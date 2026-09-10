import AppKit
import FundamentalPresentation

extension MacAccessibilityTree
{
    static func listGroups(
        _ residents: [PresentedResident]
    ) -> [UUID: [PresentedResident]]
    {
        var groups: [UUID: [PresentedResident]] = [:]
        for resident in residents
        {
            guard resident.content.listItem != nil
            else
            {
                continue
            }
            groups[resident.residentID.blockID, default: []].append(resident)
        }
        return groups.mapValues
        {
            $0.sorted
            {
                $0.residentID.fragmentOrdinal < $1.residentID.fragmentOrdinal
            }
        }
    }
}
