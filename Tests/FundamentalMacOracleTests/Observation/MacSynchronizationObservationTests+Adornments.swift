import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacSynchronizationObservationTests
{
    @Test("adornment synchronization records rather than freezes policy")
    func adornments() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        let model = controller.readerView.model
        let (first, last) = try MacReaderRasterPublicationTests.positions(
            in: model
        )
        #expect(model.showCaret(at: first))
        let caret = try MacSynchronizationObservation(controller)
        #expect(caret.form == "caret")
        #expect(controller.readerView.synchronizeFromScrollView())
        let afterCaret = try MacSynchronizationObservation(controller)
        #expect(caret.execution.documentExecution
            === afterCaret.execution.documentExecution)
        caret.report("caret", after: afterCaret)
        #expect(model.showSelection(anchor: first, focus: last))
        let selection = try MacSynchronizationObservation(controller)
        #expect(selection.form == "selection")
        #expect(controller.readerView.synchronizeFromScrollView())
        let afterSelection = try MacSynchronizationObservation(controller)
        #expect(selection.execution.documentExecution
            === afterSelection.execution.documentExecution)
        selection.report("selection", after: afterSelection)
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
    }
}
