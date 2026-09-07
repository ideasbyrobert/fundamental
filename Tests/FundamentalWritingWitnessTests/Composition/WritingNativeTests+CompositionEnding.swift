import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("cancellation leaves canonical content and retained history intact",
          arguments: ["escape", "undo", "redo", "projection"])
    func cancel(_ action: String) throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.select(1)
        window.commit("X")
        let before = window.storage
        window.mark("draft")
        switch action
        {
        case "escape": window.view.cancelOperation(nil)
        case "undo": window.view.undoCanonicalEdit(nil)
        case "redo": window.view.redoCanonicalEdit(nil)
        default: window.controller.bridge.project(in: window.view)
        }
        #expect(window.storage == before)
        #expect(!window.view.hasMarkedText())
        try window.expect("AXB", selection: NSRange(location: 2, length: 0))
        window.view.undoCanonicalEdit(nil)
        try window.expect("AB", selection: NSRange(location: 1, length: 0))
    }

    @Test("unmarking selection and focus changes accept composition once",
          arguments: ["unmark", "selection", "focus"])
    func finish(_ action: String) throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.select(1)
        window.mark("é")
        switch action
        {
        case "selection": window.select(0)
        case "focus":
            #expect(window.controller.documentWindow.makeFirstResponder(nil))
        default: window.view.unmarkText()
        }
        #expect(!window.view.hasMarkedText())
        #expect(window.session.history.undo.count == 1)
        try window.expect("AéB", selection: NSRange(
            location: action == "selection" ? 0 : 2, length: 0
        ))
    }

    @Test("accepting unchanged spelling creates no content history")
    func unchanged() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.select(0, 1)
        let revision = window.session.document.revision
        window.mark("A")
        window.commit("A")
        try window.expect("AB", selection: NSRange(location: 1, length: 0))
        #expect(window.session.document.revision == revision)
        #expect(window.session.history.undo.isEmpty)
    }
}
