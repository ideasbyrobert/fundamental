import AppKit
import FundamentalPresentation

extension MacAccessibilityTree
{
    static func lineWitness(
        _ resident: PresentedResident,
        semantics: MacAccessibilitySemantics,
        tableID: UUID,
        tableOrdinal: Int,
        row: Int,
        cell: Int
    ) -> (PresentedResident, MacAccessibilitySemantics)?
    {
        guard resident.residentID.blockID == tableID,
              resident.residentID.blockOrdinal == tableOrdinal
        else
        {
            return nil
        }
        switch (semantics, resident.content)
        {
        case let (
            .headerCell,
            .headerCell(sourceRow, sourceCell, .line(line))
        ) where sourceRow == row
            && sourceCell == cell
            && !line.text.isEmpty:
            return (resident, .headerCellText(line.text))
        case let (
            .bodyCell,
            .bodyCell(sourceRow, sourceCell, .line(line))
        ) where sourceRow == row
            && sourceCell == cell
            && !line.text.isEmpty:
            return (resident, .bodyCellText(line.text))
        default:
            return nil
        }
    }
}
