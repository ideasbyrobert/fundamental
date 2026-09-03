import AppKit
import FundamentalPresentation

@MainActor
enum MacAccessibilityTree
{
    static func elements(
        document: PresentedDocument,
        view: NSView,
        horizontalInset: Double
    ) -> [MacAccessibilityElement]
    {
        elements(
            residents: document.residents.all,
            view: view,
            horizontalInset: horizontalInset
        )
    }

    static func elements(
        residents: [PresentedResident],
        view: NSView,
        horizontalInset: Double
    ) -> [MacAccessibilityElement]
    {
        var result: [MacAccessibilityElement] = []
        for resident in residents
        {
            switch resident.content
            {
            case let .body(line):
                result.append(element(
                    .body(line.text),
                    resident: resident,
                    view: view,
                    horizontalInset: horizontalInset
                ))
            case let .title(line):
                result.append(element(
                    .title(line.text),
                    resident: resident,
                    view: view,
                    horizontalInset: horizontalInset
                ))
            case let .section(level, line):
                result.append(element(
                    .section(level: level.rawValue, value: line.text),
                    resident: resident,
                    view: view,
                    horizontalInset: horizontalInset
                ))
            case let .code(line):
                result.append(element(
                    .code(line.text),
                    resident: resident,
                    view: view,
                    horizontalInset: horizontalInset
                ))
            case .caption:
                break
            case .table:
                result.append(table(
                    resident,
                    residents: residents,
                    view: view,
                    horizontalInset: horizontalInset
                ))
            case .tableColumn,
                 .headerRow,
                 .bodyRow,
                 .headerCell,
                 .bodyCell:
                break
            }
        }
        return result
    }

    private static func table(
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

    private static func caption(
        for table: PresentedResident,
        residents: [PresentedResident],
        view: NSView,
        horizontalInset: Double,
        parent: MacAccessibilityElement
    ) -> MacAccessibilityElement?
    {
        let lines = residents.compactMap
        {
            resident -> (PresentedResident, String)? in
            guard resident.residentID.blockID
                    == table.residentID.blockID,
                  resident.residentID.blockOrdinal
                    == table.residentID.blockOrdinal,
                  case let .caption(line) = resident.content
            else
            {
                return nil
            }
            return (resident, line.text)
        }.sorted
        {
            $0.0.residentID.fragmentOrdinal
                < $1.0.residentID.fragmentOrdinal
        }
        guard let first = lines.first
        else
        {
            return nil
        }
        let frame = lines.dropFirst().reduce(screenFrame(
            first.0,
            view: view,
            horizontalInset: horizontalInset
        ))
        {
            result, line in
            result.union(screenFrame(
                line.0,
                view: view,
                horizontalInset: horizontalInset
            ))
        }
        return element(
            .caption(lines.map(\.1).joined()),
            frame: frame,
            parent: parent
        )
    }

    private static func row(
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

    private static func cellElements(
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

    private static func cellElement(
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

    private static func lineWitness(
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

    private static func element(
        _ semantics: MacAccessibilitySemantics,
        resident: PresentedResident,
        view: NSView,
        horizontalInset: Double,
        parent: AnyObject? = nil
    ) -> MacAccessibilityElement
    {
        element(
            semantics,
            frame: screenFrame(
                resident,
                view: view,
                horizontalInset: horizontalInset
            ),
            parent: parent ?? view
        )
    }

    private static func screenFrame(
        _ resident: PresentedResident,
        view: NSView,
        horizontalInset: Double
    ) -> NSRect
    {
        let local = NSRect(
            x: resident.frame.minX + horizontalInset,
            y: resident.frame.minY,
            width: resident.frame.size.width,
            height: resident.frame.size.height
        )
        let windowFrame = view.convert(local, to: nil)
        return view.window?.convertToScreen(windowFrame)
            ?? windowFrame
    }

    private static func element(
        _ semantics: MacAccessibilitySemantics,
        frame: NSRect,
        parent: AnyObject
    ) -> MacAccessibilityElement
    {
        return MacAccessibilityElement(
            semantics: semantics,
            frame: frame,
            parent: parent
        )
    }
}
