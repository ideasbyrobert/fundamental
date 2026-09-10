import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("Text controls preserve caret typing Return paste and history",
          arguments: WritingInlineFixture.traits, [false, true])
    func inlineControlsCaret(_ trait: SemanticInlineTrait, toolbar: Bool) throws
    {
        let window = try WritingTestWindow(styles: [.body], texts: [""])
        let board = NSPasteboard.withUniqueName()
        defer
        {
            board.releaseGlobally()
            window.close()
        }
        let original = window.session.document
        try window.chooseInline(trait, toolbar: toolbar)
        try window.expectInline(trait, .on)
        #expect(window.session.document == original)
        #expect(!window.session.isDirty && window.session.history.undo.isEmpty)
        #expect(window.controller.documentWindow.firstResponder === window.view)
        try window.key("x", code: 7)
        try window.key("\r", code: 36)
        #expect(board.setString("e\u{301}😀", forType: .string))
        window.view.paste(board)
        try window.expect("x\ne\u{301}😀", selection: NSRange(
            location: 6, length: 0
        ))
        let runs = try WritingInlineFixture.runs(window.session.document)
        #expect(runs.count == 2)
        #expect(runs.allSatisfy { $0.traits == [trait] })
        #expect(window.session.history.undo.count == 3)
        try window.chooseInline(trait, toolbar: toolbar)
        try window.expectInline(trait, .off)
        try window.key("y", code: 16)
        let last = try #require(WritingInlineFixture.runs(
            window.session.document
        ).last)
        #expect(last.text == "y" && last.traits.isEmpty)
        for _ in 0 ..< 4
        {
            window.view.undoCanonicalEdit(nil)
        }
        #expect(window.session.document.content == original.content)
        #expect(!window.session.isDirty)
        try window.expectInline(trait, .on)
        try WritingWindowGeometry.expectVisibleCaret(window)
    }
}
