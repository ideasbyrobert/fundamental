import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacReaderInteractionTests
{
    @Test("reader first responder copies into a named pasteboard")
    func nativeDragAndCopy() throws
    {
        let controller = try MacOracleTestSurface.window()
        let window = try #require(controller.window)
        controller.showWindow(nil)
        controller.synchronize()
        let view = controller.readerView
        let document = view.model.snapshot.presentedDocument
        let (_, line) = try Self.line(in: view.model.snapshot)
        let first = try #require(line.caretSites.first)
        let last = try #require(line.caretSites.last)
        view.mouseDown(with: try Self.event(
            type: .leftMouseDown,
            site: first,
            view: view,
            window: window
        ))
        view.mouseDragged(with: try Self.event(
            type: .leftMouseDragged,
            site: last,
            view: view,
            window: window
        ))
        guard case let .selection(_, selection) = view.model.snapshot
        else
        {
            Issue.record("The selection was not published")
            return
        }
        #expect(view.model.snapshot.presentedDocument.sharesStorage(
            with: document
        ))
        let name = NSPasteboard.Name("Fundamental.Etude69.Copy")
        let pasteboard = NSPasteboard(name: name)
        pasteboard.clearContents()
        let sender = MacCopyDestination(pasteboard: pasteboard)
        #expect(window.makeFirstResponder(view))
        #expect(window.firstResponder === view)
        #expect(view.responds(to: #selector(NSText.copy(_:))))
        #expect(view.tryToPerform(
            #selector(NSText.copy(_:)),
            with: sender
        ))
        #expect(pasteboard.string(forType: .string) == selection.text)
        pasteboard.clearContents()
        window.close()
    }
}
