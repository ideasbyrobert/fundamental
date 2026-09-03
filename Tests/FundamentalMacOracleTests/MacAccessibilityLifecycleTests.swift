import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacAccessibilityGeometryTests
{
    @Test("detaching a reader removes its published accessibility tree")
    func detachingReaderRemovesAccessibility() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        let view = controller.readerView
        let generation = view.model.snapshot.lineage.generation
        let layoutExecutions = view.model.layoutExecutionCount
        let before = try #require(
            view.accessibilityChildren() as? [MacAccessibilityElement]
        )
        #expect(!before.isEmpty)
        controller.scrollView.documentView = nil
        let after = try #require(
            view.accessibilityChildren() as? [MacAccessibilityElement]
        )
        #expect(view.window == nil)
        #expect(after.isEmpty)
        #expect(view.model.snapshot.lineage.generation == generation)
        #expect(view.model.layoutExecutionCount == layoutExecutions)
    }
}
