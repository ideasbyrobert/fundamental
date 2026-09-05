import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

@MainActor
struct WritingTestWindow
{
    let session: DocumentSession
    let controller: WritingWindowController

    init(_ text: String = "") throws
    {
        try self.init(session: DocumentSession(
            state: WritingTestDocument(text).state
        ))
    }

    init(
        session: DocumentSession,
        size: NSSize = NSSize(width: 820, height: 600),
        decision: @escaping @MainActor () -> WritingCloseDecision = { .cancel }
    ) throws
    {
        _ = NSApplication.shared
        self.session = session
        let candidate = WritingWindowController(
            session: session,
            size: size,
            confirmDiscard: decision
        )
        controller = try #require(candidate)
        controller.documentWindow.animationBehavior = .none
        controller.showWindow(nil)
    }

    var view: WritingTextView
    {
        controller.textView
    }

    var storage: DocumentSessionStorage
    {
        DocumentSessionStorage(state: session.state, history: session.history)
    }

    func close()
    {
        controller.documentWindow.delegate = nil
        controller.documentWindow.close()
    }

    func select(_ location: Int, _ length: Int = 0)
    {
        view.setSelectedRange(NSRange(location: location, length: length))
    }

    func expect(_ text: String, selection: NSRange) throws
    {
        let current = try #require(WritingProjection(session.state))
        #expect(current.text.utf16.elementsEqual(text.utf16))
        #expect(view.string.utf16.elementsEqual(text.utf16))
        #expect(current.selection == selection)
        #expect(view.selectedRange() == selection)
        #expect(view.textLayoutManager != nil)
        #expect(!view.allowsUndo)
        #expect(view.undoManager?.canUndo != true)
    }

    func key(_ text: String, code: UInt16) throws
    {
        let event = try #require(NSEvent.keyEvent(
            with: .keyDown,
            location: .zero,
            modifierFlags: [],
            timestamp: 1,
            windowNumber: controller.documentWindow.windowNumber,
            context: nil,
            characters: text,
            charactersIgnoringModifiers: text,
            isARepeat: false,
            keyCode: code
        ))
        controller.documentWindow.sendEvent(event)
    }
}
