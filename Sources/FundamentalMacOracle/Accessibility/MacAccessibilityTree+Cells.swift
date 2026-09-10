import AppKit
import FundamentalPresentation

extension MacAccessibilityTree
{
    static func cellElements(
        tableID: UUID,
        tableOrdinal: Int,
        row: Int,
        rowSemantics: MacAccessibilitySemantics,
        residents: [PresentedResident],
        view: NSView,
        horizontalInset: Double,
        parent: MacAccessibilityElement
    ) -> [MacAccessibilityElement]
    {
        let cells = residents.compactMap
        {
            resident
                -> (PresentedResident, Int, PresentedTableCellGeometry)? in
            guard resident.residentID.blockID == tableID,
                  resident.residentID.blockOrdinal == tableOrdinal
            else
            {
                return nil
            }
            switch (rowSemantics, resident.content)
            {
            case let (
                .headerRow,
                .headerCell(sourceRow, cell, .area(geometry))
            ) where sourceRow == row:
                return (resident, cell, geometry)
            case let (
                .bodyRow,
                .bodyCell(sourceRow, cell, .area(geometry))
            ) where sourceRow == row:
                return (resident, cell, geometry)
            default:
                return nil
            }
        }.sorted
        {
            $0.1 < $1.1
        }
        return cells.compactMap
        {
            let semantics: MacAccessibilitySemantics
            switch $0.0.content
            {
            case .headerCell:
                semantics = .headerCell($0.2)
            case .bodyCell:
                semantics = .bodyCell($0.2)
            default:
                return nil
            }
            return cellElement(
                semantics,
                resident: $0.0,
                row: row,
                cell: $0.1,
                residents: residents,
                view: view,
                horizontalInset: horizontalInset,
                parent: parent
            )
        }
    }
}
