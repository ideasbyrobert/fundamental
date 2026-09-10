import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension WritingMixedDocumentFixture
{
    static func copy(
        _ block: IdentifiedSemanticBlock, residents: [PresentedResident],
        from controller: MacReaderWindowController
    ) throws
    {
        let view = controller.readerView
        let window = try #require(controller.window)
        let lines = residents.compactMap(\.content.textLine)
        let first = try #require(lines.first)
        let last = try #require(lines.last)
        let end = try #require(last.caretSites.last)
        let source = try #require(EditableSemanticBlock(block.block))
            .runs.map(\.text).joined()
        let startEvent = try pointer(.leftMouseDown,
            x: first.firstCaretSite.position.x, line: first,
            view: view, window: window)
        view.mouseDown(with: startEvent)
        if source.isEmpty
        {
            guard case .caret = view.model.snapshot
            else
            {
                Issue.record("An empty list item did not retain its caret")
                return
            }
            return
        }
        view.mouseDragged(with: try pointer(.leftMouseDragged,
            x: end.position.x, line: last, view: view, window: window))
        guard case let .selection(_, selection) = view.model.snapshot
        else
        {
            Issue.record("Mixed-document source selection was refused")
            return
        }
        #expect(selection.text.utf16.elementsEqual(source.utf16))
        let pasteboard = NSPasteboard.withUniqueName()
        defer { pasteboard.releaseGlobally() }
        #expect(window.makeFirstResponder(view))
        #expect(view.tryToPerform(#selector(NSText.copy(_:)),
            with: MacCopyDestination(pasteboard: pasteboard)))
        let copied = try #require(pasteboard.string(forType: .string))
        #expect(copied.utf16.elementsEqual(source.utf16))
    }

    static func pointer(
        _ type: NSEvent.EventType, x: Double, line: PresentedTextLine,
        view: MacReaderView, window: NSWindow
    ) throws -> NSEvent
    {
        let point = NSPoint(x: x + view.horizontalInset,
            y: line.lineBounds.minY + line.lineBounds.size.height / 2)
        try #require(view.visibleRect.contains(point))
        return try #require(NSEvent.mouseEvent(
            with: type, location: view.convert(point, to: nil),
            modifierFlags: [], timestamp: 1,
            windowNumber: window.windowNumber, context: nil,
            eventNumber: 1, clickCount: 1, pressure: 1
        ))
    }
}
