import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingAcceptanceTests
{
    @Test
    func discardedNativeSpellingCannotOwnRebuiltCanonicalHistory() throws
    {
        let seed = try #require(WritingDocumentSeed())
        let session = DocumentSession(state: seed.state)
        let text = String(repeating: "A readable sentence. ", count: 500)
        let caret = NSRange(location: text.utf16.count, length: 0)
        weak var priorBridge: WritingNativeBridge?
        let retained = try autoreleasepool
        {
            let original = try WritingTestWindow(session: session)
            priorBridge = original.controller.bridge
            original.view.insertText(text, replacementRange: NSRange(
                location: NSNotFound, length: 0
            ))
            let retained = original.storage
            original.view.delegate = nil
            original.view.string = ""
            #expect(original.view.string.isEmpty)
            #expect(original.storage == retained)
            original.close()
            return retained
        }
        #expect(priorBridge == nil)
        let rebuilt = try WritingTestWindow(session: session)
        defer
        {
            rebuilt.close()
        }
        #expect(rebuilt.storage == retained)
        try rebuilt.expect(text, selection: caret)
        try WritingWindowGeometry.expectVisibleCaret(rebuilt)
        rebuilt.view.undoCanonicalEdit(nil)
        try rebuilt.expect("", selection: NSRange(location: 0, length: 0))
        try WritingWindowGeometry.expectVisibleCaret(rebuilt)
        rebuilt.view.redoCanonicalEdit(nil)
        try rebuilt.expect(text, selection: caret)
        try WritingWindowGeometry.expectVisibleCaret(rebuilt)
        #expect(session.state.snapshot.document.revision.value == 3)
        #expect(session.state.snapshot.generation.value == 3)
        #expect(session.history.undo.count == 1)
        #expect(session.history.redo.isEmpty)
    }
}
