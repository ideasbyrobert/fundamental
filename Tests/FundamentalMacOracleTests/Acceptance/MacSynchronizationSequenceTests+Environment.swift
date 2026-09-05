import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacSynchronizationSequenceTests
{
    @Test("measure height and appearance changes publish current native facts")
    func environment() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        defer { window.close() }
        window.appearance = try MacOracleTestSurface.appearance(.aqua)
        controller.showWindow(nil)
        let view = controller.readerView
        let initial = view.model.snapshot
        let layouts = view.model.layoutExecutionCount
        window.setContentSize(NSSize(width: 600, height: 680))
        #expect(view.synchronizeFromScrollView())
        #expect(view.model.snapshot.lineage.generation
            > initial.lineage.generation)
        #expect(view.model.layoutExecutionCount == layouts + 1)
        #expect(view.model.readableMeasure == 536)
        let narrow = view.model.snapshot
        window.setContentSize(NSSize(width: 600, height: 720))
        #expect(view.synchronizeFromScrollView())
        #expect(view.model.snapshot.lineage.generation
            > narrow.lineage.generation)
        #expect(controller.scrollView.contentView.bounds.height == 720)
        #expect(view.model.layoutExecutionCount == layouts + 1)
        let tall = view.model.snapshot
        window.appearance = try MacOracleTestSurface.appearance(.darkAqua)
        #expect(view.synchronizeFromScrollView())
        let dark = view.model.snapshot
        #expect(dark.lineage.generation > tall.lineage.generation)
        #expect(dark.presentedDocument.plane.appearance
            != tall.presentedDocument.plane.appearance)
        #expect(dark.presentedDocument.plane.palette
            != tall.presentedDocument.plane.palette)
        #expect(view.model.layoutExecutionCount == layouts + 1)
        try MacReaderEnvironmentTestSupport.expectCurrent(controller)
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
        #expect(view.synchronizeFromScrollView())
        #expect(view.model.snapshot == dark)
    }
}
