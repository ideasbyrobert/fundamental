import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

@MainActor
struct WritingAcceptanceScenario
{
    let window: WritingTestWindow
    let pasteboard: NSPasteboard

    init() throws
    {
        let seed = try #require(WritingDocumentSeed())
        window = try WritingTestWindow(session: DocumentSession(
            state: seed.state
        ))
        pasteboard = .withUniqueName()
    }

    func close()
    {
        pasteboard.releaseGlobally()
        window.close()
    }

    func expect(
        _ text: String,
        _ location: Int,
        _ length: Int = 0,
        revision: UInt64,
        generation: UInt64,
        undo: Int,
        redo: Int = 0
    ) throws
    {
        try window.expect(text, selection: NSRange(
            location: location, length: length
        ))
        let snapshot = window.session.state.snapshot
        #expect(snapshot.document.revision.value == revision)
        #expect(snapshot.generation.value == generation)
        #expect(window.session.history.undo.count == undo)
        #expect(window.session.history.redo.count == redo)
        #expect(snapshot.document.content.blocks.count == 1)
    }

    func insert(_ text: String)
    {
        window.view.insertText(text, replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
    }

    func history(_ direction: DocumentHistoryDirection) throws
    {
        let responder = try #require(
            window.controller.documentWindow.firstResponder
        )
        let action: Selector
        switch direction
        {
        case .undo:
            action = #selector(WritingTextView.undoCanonicalEdit)
        case .redo:
            action = #selector(WritingTextView.redoCanonicalEdit)
        }
        #expect(responder.tryToPerform(action, with: nil))
    }
}
