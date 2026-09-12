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

    @Test("owned menus contain admitted commands before system augmentation")
    func witnessMenuContainsOnlyAdmittedCommands() throws
    {
        _ = NSApplication.shared
        let menu = WritingApplicationMenu.make()
        #expect(menu.items.map(\.title) == [
            "Fundamental", "File", "Edit", "Format"
        ])
        let file = try #require(menu.item(withTitle: "File")?.submenu)
        let edit = try #require(menu.item(withTitle: "Edit")?.submenu)
        let format = try #require(menu.item(withTitle: "Format")?.submenu)
        #expect(format.items.map(\.title) == [
            "Paragraph Style", "Text Style", "List"
        ])
        #expect(file.items.map(\.title) == [
            "New", "Open…", "", "Save", "Save As…", "",
            "Import Text…", "Export Text…", "", "Close"
        ])
        #expect(file.items.filter { !$0.isSeparatorItem }.allSatisfy
        {
            $0.target == nil
        })
        #expect(edit.items.map(\.title) == [
            "Undo", "Redo", "", "Cut", "Copy", "Paste", "Select All", "",
            "Find…", "Find and Replace…", "Find Next", "Find Previous"
        ])
        #expect(edit.items.filter { !$0.isSeparatorItem }.allSatisfy
        {
            $0.target == nil
        })
        #expect(edit.items[0].keyEquivalent == "z")
        #expect(edit.items[1].keyEquivalent == "Z")
        #expect(edit.items[1].keyEquivalentModifierMask == [.command])
        #expect(edit.items[8...11].map(\.keyEquivalent) == ["f", "f", "g", "g"])
        #expect(edit.items[9].keyEquivalentModifierMask == [.command, .option])
        #expect(edit.items[11].keyEquivalentModifierMask == [.command, .shift])
    }
}
