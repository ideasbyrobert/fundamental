import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test
    func nativeHistoryActionsRestoreCanonicalCheckpoints() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.select(1, 1)
        window.view.insertText("X", replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        window.view.undoCanonicalEdit(nil)
        try window.expect("AB", selection: NSRange(location: 1, length: 1))
        #expect(window.session.state.snapshot.document.revision.value == 10)
        #expect(window.session.state.snapshot.generation.value == 6)
        #expect(!window.session.canUndo)
        #expect(window.session.canRedo)
        window.view.redoCanonicalEdit(nil)
        try window.expect("AX", selection: NSRange(location: 2, length: 0))
        #expect(window.session.state.snapshot.document.revision.value == 11)
        #expect(window.session.state.snapshot.generation.value == 7)
        #expect(window.session.canUndo)
        #expect(!window.session.canRedo)
    }

    @Test
    func nativeHistoryValidationReflectsCanonicalStacks() throws
    {
        let window = try WritingTestWindow()
        defer
        {
            window.close()
        }
        let undo = NSMenuItem(title: "Undo", action:
            #selector(WritingTextView.undoCanonicalEdit), keyEquivalent: "z")
        let redo = NSMenuItem(title: "Redo", action:
            #selector(WritingTextView.redoCanonicalEdit), keyEquivalent: "z")
        #expect(!window.view.validateUserInterfaceItem(undo))
        #expect(!window.view.validateUserInterfaceItem(redo))
        window.view.insertText("A", replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        #expect(window.view.validateUserInterfaceItem(undo))
        #expect(!window.view.validateUserInterfaceItem(redo))
        window.view.undoCanonicalEdit(nil)
        #expect(!window.view.validateUserInterfaceItem(undo))
        #expect(window.view.validateUserInterfaceItem(redo))
        let before = window.storage
        window.view.insertNewline(nil)
        #expect(window.storage == before)
        #expect(window.view.validateUserInterfaceItem(redo))
    }
}
