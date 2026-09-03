import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacAccessibilityTests
{
    @Test("native table structure preserves semantic source order")
    func tableStructurePreservesSourceOrder() throws
    {
        let residents = try MacSummitScan().residents
        let view = NSView(frame: NSRect(
            x: 0,
            y: 0,
            width: 820,
            height: 10_000
        ))
        let tables = MacAccessibilityTree.elements(
            residents: residents,
            view: view,
            horizontalInset: 0
        ).filter
        {
            role($0) == .table
        }
        #expect(tables.count == 2)
        for table in tables
        {
            let tableRows = rows(table)
            #expect(tableRows.count == 2)
            if tableRows.count == 2
            {
                guard case .headerRow = tableRows[0].semantics,
                      case .bodyRow = tableRows[1].semantics
                else
                {
                    Issue.record("The source row order changed")
                    continue
                }
                #expect(cellIndices(rows(tableRows[0])) == [0, 1, 2])
                #expect(cellIndices(rows(tableRows[1])) == [0, 1])
            }
        }
    }

    func cellIndices(
        _ cells: [MacAccessibilityElement]
    ) -> [Int]
    {
        cells.compactMap
        {
            switch $0.semantics
            {
            case let .headerCell(geometry),
                 let .bodyCell(geometry):
                geometry.sourceCell
            default:
                nil
            }
        }
    }
}
