import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacReaderWindowTests
{
    @Test("unchanged screen and backing entries retain current facts")
    func displayDelegateEntriesRetainCurrentFacts() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        let before = controller.readerView.model.snapshot
        let layoutExecutions = controller.readerView.model
            .layoutExecutionCount
        #expect(window.delegate === controller)
        controller.windowDidChangeScreen(Notification(
            name: NSWindow.didChangeScreenNotification,
            object: window
        ))
        try MacReaderEnvironmentTestSupport.expectCurrent(controller)
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
        let afterScreen = controller.readerView.model.snapshot
        controller.windowDidChangeBackingProperties(Notification(
            name: NSWindow.didChangeBackingPropertiesNotification,
            object: window
        ))
        try MacReaderEnvironmentTestSupport.expectCurrent(controller)
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
        let afterBacking = controller.readerView.model.snapshot
        #expect(afterScreen == before)
        #expect(afterBacking == before)
        #expect(controller.readerView.model.layoutExecutionCount
            == layoutExecutions)
    }
}
