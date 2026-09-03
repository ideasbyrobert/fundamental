import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacAccessibilityTests
{
    @Test("wrapped spanning and empty cells retain exact native areas")
    func cellsRetainAreasAndLines() throws
    {
        let residents = try MacSummitScan(
            width: 160,
            height: 680
        ).residents
        let view = NSView(frame: NSRect(
            x: 0,
            y: 0,
            width: 160,
            height: 10_000
        ))
        let nodes = MacAccessibilityTree.elements(
            residents: residents,
            view: view,
            horizontalInset: 0
        )
        let tables = nodes.filter
        {
            role($0) == .table
        }
        #expect(tables.count == 2)
        let cells = tables.flatMap
        {
            rows($0).flatMap(rows)
        }
        #expect(cells.count == 10)
        let spanning = try #require(cells.first
        {
            guard let range = $0.accessibilityAttributeValue(
                .columnIndexRange
            ) as? NSValue
            else
            {
                return false
            }
            return range.rangeValue.length == 2
        })
        let wrapped = rows(spanning)
        #expect(wrapped.count > 1)
        #expect(wrapped.allSatisfy
        {
            role($0) == .staticText
                && value($0) != nil
        })
        let empty = try #require(cells.first
        {
            rows($0).isEmpty
        })
        #expect(role(empty) == .cell)
        #expect(empty.accessibilityAttributeValue(.value) == nil)
        let captioned = try #require(tables.first
        {
            $0.accessibilityAttributeNames().contains(.titleUIElement)
        })
        let caption = try #require(captioned.accessibilityAttributeValue(
            .titleUIElement
        ) as? MacAccessibilityElement)
        #expect(value(caption) == "The finite summit stages")
    }

    func rows(
        _ element: MacAccessibilityElement
    ) -> [MacAccessibilityElement]
    {
        element.accessibilityAttributeValue(.children)
            as? [MacAccessibilityElement] ?? []
    }
}
