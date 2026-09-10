import AppKit
import FundamentalPresentation

extension MacAccessibilityTree
{
    static func row(
        _ semantics: MacAccessibilitySemantics,
        resident: PresentedResident,
        row: Int,
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
        let cells = cellElements(
            tableID: resident.residentID.blockID,
            tableOrdinal: resident.residentID.blockOrdinal,
            row: row,
            rowSemantics: semantics,
            residents: residents,
            view: view,
            horizontalInset: horizontalInset,
            parent: element
        )
        element.replaceChildren(cells)
        return element
    }
}
