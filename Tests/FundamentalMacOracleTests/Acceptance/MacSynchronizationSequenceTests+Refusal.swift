import AppKit
import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacSynchronizationSequenceTests
{
    @Test("poisoned current work and later stale work preserve the window")
    func refusal() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        defer { window.close() }
        window.appearance = try MacOracleTestSurface.appearance(.aqua)
        controller.showWindow(nil)
        let view = controller.readerView
        let model = view.model
        let (first, last) = try MacReaderRasterPublicationTests.positions(
            in: model
        )
        #expect(model.showCaret(at: first))
        #expect(view.synchronizeFromScrollView())
        let before = try MacSynchronizationObservation(controller)
        let (preparation, surface) = try MacOracleTestPreparation.make()
        var lease = try #require(preparation.reserveAttempt())
        while lease.generation < model.snapshot.lineage.generation
        {
            lease = try #require(preparation.reserveAttempt())
        }
        #expect(lease.generation == model.snapshot.lineage.generation)
        let attempt = try #require(preparation.prepare(
            surface: surface,
            intent: .caret(first),
            lease: lease
        ))
        let color = try #require(
            MacRasterSnapshotFixture.mismatchedColor(in: attempt.snapshot)
        )
        let poisoned = try #require(
            MacRasterSnapshotFixture.replacingCaretColor(
                in: attempt.snapshot,
                with: color
            )
        )
        let refused = SummitPresentationAttempt(
            snapshot: poisoned,
            lease: lease,
            raster: attempt.raster,
            surface: surface
        )
        #expect(MacRasterExecutor().admit(attempt.snapshot) != nil)
        #expect(MacRasterExecutor().admit(poisoned) == nil)
        #expect(!model.publish(refused))
        #expect(model.snapshot == before.snapshot)
        MacReaderRasterPublicationTests.expectSameExecution(
            before.execution,
            model.rasterExecution
        )
        #expect(model.showSelection(anchor: first, focus: last))
        #expect(view.synchronizeFromScrollView())
        let selected = try MacSynchronizationObservation(controller)
        #expect(attempt.lease.generation < selected.snapshot.lineage.generation)
        #expect(!model.publish(attempt))
        #expect(view.synchronizeFromScrollView())
        #expect(model.snapshot == selected.snapshot)
        MacReaderRasterPublicationTests.expectSameExecution(
            selected.execution,
            model.rasterExecution
        )
        #expect(model.layoutExecutionCount == selected.layoutExecutions)
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
    }
}
