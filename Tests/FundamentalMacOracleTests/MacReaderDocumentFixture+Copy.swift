import AppKit
import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacReaderDocumentFixture
{
    static func copy(
        blockID: UUID, from controller: MacReaderWindowController,
        reverse: Bool = false
    ) throws -> PresentationSelectionAdornment
    {
        let window = try #require(controller.window)
        let view = controller.readerView
        let document = view.model.snapshot.presentedDocument
        let lines = document.residents.all.filter
        {
            $0.residentID.blockID == blockID
        }.compactMap { line($0.content) }
        let firstLine = try #require(lines.first)
        let lastLine = try #require(lines.last)
        let first = try mouseSite(firstLine.firstCaretSite, line: firstLine)
        let last = try mouseSite(
            #require(lastLine.caretSites.last), line: lastLine
        )
        view.mouseDown(with: try MacReaderInteractionTests.event(
            type: .leftMouseDown, site: reverse ? last : first,
            view: view, window: window
        ))
        view.mouseDragged(with: try MacReaderInteractionTests.event(
            type: .leftMouseDragged, site: reverse ? first : last,
            view: view, window: window
        ))
        guard case let .selection(_, selection) = view.model.snapshot
        else
        {
            let diagnostic = selectionDiagnostic(lines, model: view.model)
            Issue.record("Selection refused: \(diagnostic)")
            throw MacOracleTestFailure.admission
        }
        #expect(view.model.snapshot.presentedDocument.sharesStorage(
            with: document
        ))
        #expect(window.makeFirstResponder(view))
        #expect(window.firstResponder === view)
        let name = NSPasteboard.Name("Fundamental.Etude106.DocumentInput")
        let pasteboard = NSPasteboard(name: name)
        pasteboard.clearContents()
        defer { pasteboard.clearContents() }
        let destination = MacCopyDestination(pasteboard: pasteboard)
        #expect(view.tryToPerform(#selector(NSText.copy(_:)),
                                  with: destination))
        let copied = try #require(pasteboard.string(forType: .string))
        #expect(copied.utf16.elementsEqual(selection.text.utf16))
        return selection
    }
}
