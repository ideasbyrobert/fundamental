import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacSynchronizationSequenceTests
{
    @Test("centered resizing and window movement retain selected content")
    func geometry() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        let view = controller.readerView
        let (first, last) = try MacReaderRasterPublicationTests.positions(
            in: view.model
        )
        #expect(view.model.showSelection(anchor: first, focus: last))
        #expect(view.synchronizeFromScrollView())
        let before = try MacSynchronizationObservation(controller)
        let windowOrigin = window.frame.origin
        for width in [900.0, 1_200.0]
        {
            window.setContentSize(NSSize(width: width, height: 680))
            #expect(view.synchronizeFromScrollView())
            let after = try MacSynchronizationObservation(controller)
            #expect(after.snapshot == before.snapshot)
            let actualWidth = Double(after.viewSize.width)
            #expect(actualWidth > Double(before.viewSize.width))
            #expect(after.layoutExecutions == before.layoutExecutions)
            #expect(window.frame.origin == windowOrigin)
            let delta = (actualWidth - Double(before.viewSize.width)) / 2
            let expectedX = Double(before.accessibilityFrame.minX) + delta
            #expect(Double(after.accessibilityFrame.minX).bitPattern
                == expectedX.bitPattern)
            #expect(view.horizontalInset == (actualWidth - 720) / 2)
            MacReaderRasterPublicationTests.expectSameExecution(
                before.execution,
                after.execution
            )
            try MacAccessibilityGeometryTestSupport.expectSettled(controller)
        }
        let wide = try MacSynchronizationObservation(controller)
        window.setFrameOrigin(NSPoint(
            x: windowOrigin.x + 37,
            y: windowOrigin.y + 29
        ))
        let moved = try MacSynchronizationObservation(controller)
        let deltaX = window.frame.minX - windowOrigin.x
        let deltaY = window.frame.minY - windowOrigin.y
        #expect(deltaX != 0 || deltaY != 0)
        #expect(moved.snapshot == wide.snapshot)
        #expect(moved.layoutExecutions == wide.layoutExecutions)
        #expect(moved.accessibilityFrame.minX
            == wide.accessibilityFrame.minX + deltaX)
        #expect(moved.accessibilityFrame.minY
            == wide.accessibilityFrame.minY + deltaY)
        #expect(moved.accessibilityFrame.size == wide.accessibilityFrame.size)
        MacReaderRasterPublicationTests.expectSameExecution(
            wide.execution,
            moved.execution
        )
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
    }
}
