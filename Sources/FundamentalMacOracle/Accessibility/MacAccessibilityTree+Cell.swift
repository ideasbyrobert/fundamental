import AppKit
import FundamentalPresentation

extension MacAccessibilityTree
{
    static func cellElement(
        _ semantics: MacAccessibilitySemantics,
        resident: PresentedResident,
        row: Int,
        cell: Int,
        residents: [PresentedResident],
        view: NSView,
        horizontalInset: Double,
        parent: MacAccessibilityElement
    ) -> MacAccessibilityElement
    {
        let element = self.element(
            semantics,
            resident: resident,
            view: view,
            horizontalInset: horizontalInset,
            parent: parent
        )
        let lines = residents.compactMap
        {
            lineWitness(
                $0,
                semantics: semantics,
                tableID: resident.residentID.blockID,
                tableOrdinal: resident.residentID.blockOrdinal,
                row: row,
                cell: cell
            )
        }.sorted
        {
            $0.0.residentID.fragmentOrdinal
                < $1.0.residentID.fragmentOrdinal
        }
        let children = lines.map
        {
            self.element(
                $0.1,
                resident: $0.0,
                view: view,
                horizontalInset: horizontalInset,
                parent: element
            )
        }
        element.replaceChildren(children)
        return element
    }
}
