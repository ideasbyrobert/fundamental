import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacSynchronizationObservationTests
{
    @Test("wide resize and programmatic scroll settle exact geometry")
    func geometry() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        let before = try MacSynchronizationObservation(controller)
        window.setContentSize(NSSize(width: 1_200, height: 680))
        #expect(controller.readerView.synchronizeFromScrollView())
        let wide = try MacSynchronizationObservation(controller)
        #expect(wide.layoutExecutions == before.layoutExecutions)
        #expect(wide.execution.documentExecution
            === before.execution.documentExecution)
        #expect(wide.viewSize.width > before.viewSize.width)
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
        before.report("wide", after: wide)
        let clip = controller.scrollView.contentView
        let maximum = max(
            0,
            controller.readerView.model.documentHeight - clip.bounds.height
        )
        #expect(maximum > 48)
        for origin in [24.0, 48.0, 24.0, 0.0, maximum]
        {
            clip.scroll(to: NSPoint(x: 0, y: origin))
            controller.scrollView.reflectScrolledClipView(clip)
            #expect(controller.readerView.synchronizeFromScrollView())
            #expect(controller.readerView.model.visibleOriginY == origin)
            #expect(controller.readerView.model.layoutExecutionCount
                == before.layoutExecutions)
            try MacAccessibilityGeometryTestSupport.expectSettled(controller)
        }
        wide.report(
            "scroll",
            after: try MacSynchronizationObservation(controller)
        )
    }
}
