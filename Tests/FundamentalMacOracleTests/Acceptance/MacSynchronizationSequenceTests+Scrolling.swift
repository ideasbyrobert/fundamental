import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacSynchronizationSequenceTests
{
    @Test("programmatic forward reverse and distant scrolls settle completely")
    func scrolling() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        let view = controller.readerView
        let clip = controller.scrollView.contentView
        let initial = view.model.snapshot
        let layouts = view.model.layoutExecutionCount
        let documentLineage = initial.lineage.raster.viewport.layout
        let maximum = view.model.documentHeight - clip.bounds.height
        #expect(maximum > 96)
        let (first, _) = try MacReaderRasterPublicationTests.positions(
            in: view.model
        )
        #expect(view.model.showCaret(at: first))
        for origin in [24.0, 48.0, 24.0, maximum / 2, maximum, 0.0]
        {
            let before = view.model.snapshot
            clip.scroll(to: NSPoint(x: 0, y: origin))
            controller.scrollView.reflectScrolledClipView(clip)
            #expect(view.synchronizeFromScrollView())
            let current = view.model.snapshot
            #expect(current.lineage.generation > before.lineage.generation)
            #expect(current.lineage.raster.viewport.layout == documentLineage)
            #expect(view.model.visibleOriginY == origin)
            #expect(view.model.layoutExecutionCount == layouts)
            #expect(current.presentedDocument.residents.all.count <= 192)
            guard case .document = current
            else
            {
                Issue.record("Changed surfaces must use document intent")
                return
            }
            try MacAccessibilityGeometryTestSupport.expectSettled(controller)
            #expect(view.synchronizeFromScrollView())
            #expect(view.model.snapshot == current)
        }
        #expect(view.model.visibleOriginY == 0)
    }
}
