import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacAccessibilityTests
{
    @Test("native tables expose structural rows and area cells")
    func tablesExposeStructureWithoutInventedValues() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        controller.showWindow(nil)
        controller.scrollView.contentView.scroll(to: NSPoint(
            x: 0,
            y: controller.readerView.model.documentHeight
        ))
        controller.synchronize()
        let nodes = try elements(controller.readerView)
        let tables = nodes.filter
        {
            role($0) == .table
        }
        #expect(tables.count == 2)
        let table = try #require(tables.first
        {
            $0.accessibilityAttributeNames().contains(.titleUIElement)
        })
        let regular = try #require(tables.first
        {
            !$0.accessibilityAttributeNames().contains(.titleUIElement)
        })
        #expect(regular.accessibilityAttributeValue(.titleUIElement) == nil)
        assertStructural(table, role: .table)
        let rows = try #require(
            table.accessibilityAttributeValue(.children)
                as? [MacAccessibilityElement]
        )
        #expect(rows.count == 2)
        for row in rows
        {
            assertStructural(row, role: .row)
            let cells = try #require(
                row.accessibilityAttributeValue(.children)
                    as? [MacAccessibilityElement]
            )
            #expect(!cells.isEmpty)
            for cell in cells
            {
                assertStructural(cell, role: .cell)
            }
        }
        let caption = try #require(table.accessibilityAttributeValue(
            .titleUIElement
        ) as? MacAccessibilityElement)
        #expect(role(caption) == .staticText)
        #expect(value(caption) == "The finite summit stages")
        #expect((caption.accessibilityAttributeValue(.parent)
            as? MacAccessibilityElement) === table)
        #expect(!nodes.contains
        {
            if case .caption = $0.semantics
            {
                return true
            }
            return false
        })
        window.close()
    }

    func assertStructural(
        _ element: MacAccessibilityElement,
        role expected: NSAccessibility.Role
    )
    {
        #expect(role(element) == expected)
        #expect(!element.accessibilityAttributeNames().contains(.value))
        #expect(element.accessibilityAttributeValue(.value) == nil)
    }
}
