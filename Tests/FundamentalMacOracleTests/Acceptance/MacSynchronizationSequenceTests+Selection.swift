import AppKit
import FundamentalPresentation
import Testing

@testable import FundamentalMacOracle

extension MacSynchronizationSequenceTests
{
    @Test(
        "native selection retains highlight and named-pasteboard copy",
        arguments: [false, true]
    )
    func selection(dark: Bool) throws
    {
        let controller = try MacOracleTestSurface.window(width: 1_200)
        let window = try #require(controller.window)
        defer { window.close() }
        window.appearance = try MacOracleTestSurface.appearance(
            dark ? .darkAqua : .aqua
        )
        controller.showWindow(nil)
        let view = controller.readerView
        let plain = try #require(MacBitmapSurface(view.model.snapshot))
        plain.draw(view.model.rasterExecution)
        let (resident, line) = try MacReaderInteractionTests.line(
            in: view.model.snapshot
        )
        let first = try #require(line.caretSites.first)
        let last = try #require(line.caretSites.last)
        view.mouseDown(with: try MacReaderInteractionTests.event(
            type: .leftMouseDown,
            site: first,
            view: view,
            window: window
        ))
        view.mouseDragged(with: try MacReaderInteractionTests.event(
            type: .leftMouseDragged,
            site: last,
            view: view,
            window: window
        ))
        guard case let .selection(_, selection) = view.model.snapshot
        else
        {
            Issue.record("The native drag did not publish a selection")
            return
        }
        #expect(!selection.text.isEmpty)
        #expect(selection.anchor == PresentationTextPosition(
            residentID: resident.residentID,
            sourcePoint: first.sourcePoint
        ))
        #expect(selection.focus == PresentationTextPosition(
            residentID: resident.residentID,
            sourcePoint: last.sourcePoint
        ))
        #expect(selection.text == line.text)
        let snapshot = view.model.snapshot
        let execution = view.model.rasterExecution
        let selected = try #require(MacBitmapSurface(snapshot))
        selected.draw(execution)
        #expect(!plain.changedPixels(
            from: selected,
            in: plain.pixelBounds
        ).isEmpty)
        for _ in 0 ..< 3
        {
            #expect(view.synchronizeFromScrollView())
        }
        #expect(view.model.snapshot == snapshot)
        let after = try #require(MacBitmapSurface(view.model.snapshot))
        after.draw(view.model.rasterExecution)
        #expect(selected.changedPixels(
            from: after,
            in: selected.pixelBounds
        ).isEmpty)
        let pasteboard = NSPasteboard(
            name: NSPasteboard.Name("Fundamental.Etude80.Copy")
        )
        defer { pasteboard.clearContents() }
        pasteboard.clearContents()
        let sender = MacCopyDestination(pasteboard: pasteboard)
        #expect(window.firstResponder === view)
        #expect(view.tryToPerform(#selector(NSText.copy(_:)), with: sender))
        #expect(pasteboard.string(forType: .string) == line.text)
        MacReaderRasterPublicationTests.expectSameExecution(
            execution,
            view.model.rasterExecution
        )
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
    }
}
