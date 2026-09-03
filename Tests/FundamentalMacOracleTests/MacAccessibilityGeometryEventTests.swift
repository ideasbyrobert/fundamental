import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacAccessibilityGeometryTests
{
    @Test("native scroll and resize publish only settled geometry")
    func nativeScrollAndResizePublishSettledGeometry() throws
    {
        let controller = try MacOracleTestSurface.window(
            width: 820,
            height: 300
        )
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        let view = controller.readerView
        let clip = controller.scrollView.contentView
        let layoutExecutions = view.model.layoutExecutionCount
        let beforeScrollGeneration = view.model.snapshot
            .lineage.generation
        let beforeScrollElement = try MacAccessibilityGeometryTestSupport
            .firstElement(view)
        clip.scroll(to: NSPoint(
            x: 0,
            y: view.model.documentHeight
        ))
        controller.scrollView.reflectScrolledClipView(clip)
        let afterScrollElement = try MacAccessibilityGeometryTestSupport
            .firstElement(view)
        #expect(view.model.snapshot.lineage.generation
            > beforeScrollGeneration)
        #expect(view.model.layoutExecutionCount == layoutExecutions)
        #expect(afterScrollElement !== beforeScrollElement)
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
        let beforeResizeGeneration = view.model.snapshot
            .lineage.generation
        let beforeResizeElement = afterScrollElement
        window.setContentSize(NSSize(width: 1_200, height: 360))
        let afterResizeElement = try MacAccessibilityGeometryTestSupport
            .firstElement(view)
        #expect(view.model.snapshot.lineage.generation
            > beforeResizeGeneration)
        #expect(view.model.layoutExecutionCount == layoutExecutions)
        #expect(afterResizeElement !== beforeResizeElement)
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
    }
}
