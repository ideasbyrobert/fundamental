import AppKit
import FundamentalPresentation

extension MacAccessibilityTree
{
    static func table(
        _ table: PresentedResident,
        residents: [PresentedResident],
        view: NSView,
        horizontalInset: Double
    ) -> MacAccessibilityElement
    {
        let element = self.element(
            .table,
            resident: table,
            view: view,
            horizontalInset: horizontalInset
        )
        if let caption = caption(
            for: table,
            residents: residents,
            view: view,
            horizontalInset: horizontalInset,
            parent: element
        )
        {
            element.replaceTitleElement(caption)
        }
        let rows = residents.compactMap
        {
            resident -> (PresentedResident, Int)? in
            guard resident.residentID.blockID
                    == table.residentID.blockID,
                  resident.residentID.blockOrdinal
                    == table.residentID.blockOrdinal
            else
            {
                return nil
            }
            switch resident.content
            {
            case let .headerRow(row):
                return (resident, row.index)
            case let .bodyRow(row):
                return (resident, row.index)
            default:
                return nil
            }
        }.sorted
        {
            $0.1 < $1.1
        }
        let children = rows.compactMap
        {
            witness -> MacAccessibilityElement? in
            switch witness.0.content
            {
            case .headerRow:
                return self.row(
                    .headerRow,
                    resident: witness.0,
                    row: witness.1,
                    residents: residents,
                    view: view,
                    horizontalInset: horizontalInset,
                    parent: element
                )
            case .bodyRow:
                return self.row(
                    .bodyRow,
                    resident: witness.0,
                    row: witness.1,
                    residents: residents,
                    view: view,
                    horizontalInset: horizontalInset,
                    parent: element
                )
            default:
                return nil
            }
        }
        element.replaceChildren(children)
        return element
    }
}
