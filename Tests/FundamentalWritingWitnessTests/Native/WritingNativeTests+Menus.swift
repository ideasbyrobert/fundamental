import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test
    func nativeResponderRoutesHistoryActionsToCanonicalState() throws
    {
        let window = try WritingTestWindow()
        defer
        {
            window.close()
        }
        window.view.insertText("A", replacementRange: NSRange(
            location: NSNotFound, length: 0
        ))
        let undo = #selector(WritingTextView.undoCanonicalEdit)
        let redo = #selector(WritingTextView.redoCanonicalEdit)
        let responder = try #require(
            window.controller.documentWindow.firstResponder
        )
        #expect(responder === window.view)
        #expect(responder.tryToPerform(undo, with: nil))
        try window.expect("", selection: NSRange(location: 0, length: 0))
        #expect(responder.tryToPerform(redo, with: nil))
        try window.expect("A", selection: NSRange(location: 1, length: 0))
        #expect(window.session.state.snapshot.document.revision.value == 11)
        #expect(window.session.state.snapshot.generation.value == 6)
    }

    @Test
    func nativeSelectAllAndPrivateCopyUseCanonicalSpelling() throws
    {
        let window = try WritingTestWindow("Ae\u{301}👋")
        let board = NSPasteboard.withUniqueName()
        defer
        {
            board.releaseGlobally()
            window.close()
        }
        window.view.selectAll(nil)
        window.view.copy(board)
        let copied = try #require(board.string(forType: .string))
        #expect(copied.utf16.elementsEqual("Ae\u{301}👋".utf16))
        try window.expect(copied, selection: NSRange(location: 0, length: 5))
        #expect(window.session.history.undo.isEmpty)
    }

    @Test
    func witnessMenuContainsOnlyAdmittedCommands() throws
    {
        _ = NSApplication.shared
        let previous = NSApp.mainMenu
        defer
        {
            NSApp.mainMenu = previous
        }
        WritingApplicationMenu.install(in: NSApp)
        let menu = try #require(NSApp.mainMenu)
        let file = try #require(menu.item(withTitle: "File")?.submenu)
        let edit = try #require(menu.item(withTitle: "Edit")?.submenu)
        #expect(file.items.map(\.title) == ["Close"])
        #expect(edit.items.map(\.title) == [
            "Undo", "Redo", "", "Copy", "Paste", "Select All"
        ])
        #expect(edit.items.filter { !$0.isSeparatorItem }.allSatisfy
        {
            $0.target == nil
        })
        #expect(edit.items[0].keyEquivalent == "z")
        #expect(edit.items[1].keyEquivalentModifierMask == [.command, .shift])
    }
}
