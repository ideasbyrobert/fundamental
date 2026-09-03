import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacReaderWindowTests
{
    @Test("screen and backing delegate entries publish current facts")
    func displayDelegateEntriesPublishCurrentFacts() throws
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
        #expect(afterScreen.lineage.generation > before.lineage.generation)
        #expect(afterBacking.lineage.generation
            > afterScreen.lineage.generation)
        #expect(controller.readerView.model.layoutExecutionCount
            == layoutExecutions)
    }
}
