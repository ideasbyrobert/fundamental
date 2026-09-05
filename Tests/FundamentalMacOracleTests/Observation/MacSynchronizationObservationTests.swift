import AppKit
import Testing

@testable import FundamentalMacOracle

@Suite("Native synchronization observations", .serialized)
@MainActor
struct MacSynchronizationObservationTests
{
    @Test("equal synchronization retains stable document facts")
    func equalSurface() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        let before = try MacSynchronizationObservation(controller)
        for _ in 0 ..< 3
        {
            #expect(controller.readerView.synchronizeFromScrollView())
            try MacAccessibilityGeometryTestSupport.expectSettled(controller)
            try MacReaderEnvironmentTestSupport.expectCurrent(controller)
        }
        let after = try MacSynchronizationObservation(controller)
        #expect(before.execution.documentExecution
            === after.execution.documentExecution)
        #expect(before.snapshot.presentedDocument.sharesStorage(
            with: after.snapshot.presentedDocument
        ))
        #expect(before.layoutExecutions == after.layoutExecutions)
        #expect(before.origin == after.origin)
        #expect(before.viewSize == after.viewSize)
        #expect(before.accessibilityFrame == after.accessibilityFrame)
        before.report("equal", after: after)
    }
}
