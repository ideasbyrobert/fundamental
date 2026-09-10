import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("native keys Return and history retain each explicit inline choice",
          arguments: WritingInlineFixture.traits)
    func nativeInlineTyping(_ trait: SemanticInlineTrait) throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.select(1)
        try WritingInlineFixture.choose(trait, in: window)
        let base = try #require(WritingTypography.body[.font] as? NSFont)
        try WritingInlineFixture.expect([trait],
            in: window.view.typingAttributes, base: base)
        try window.key("x", code: 7)
        try window.key("\r", code: 36)
        window.commit("e\u{301}😀")
        try window.expect("Ax\ne\u{301}😀B", selection: NSRange(
            location: 7, length: 0
        ))
        let runs = try WritingInlineFixture.runs(window.session.document)
        let inserted = runs.filter { $0.text == "x" || $0.text == "e\u{301}😀" }
        #expect(inserted.count == 2)
        for run in inserted
        {
            #expect(run.traits == [trait])
        }
        #expect(window.session.history.undo.count == 3)
        let after = window.session.document.content
        for _ in 0 ..< 3
        {
            window.view.undoCanonicalEdit(nil)
        }
        #expect(window.view.string == "AB")
        try WritingInlineFixture.expect([trait],
            in: window.view.typingAttributes, base: base)
        for _ in 0 ..< 3
        {
            window.view.redoCanonicalEdit(nil)
        }
        #expect(window.session.document.content == after)
        window.select(0)
        try WritingInlineFixture.expect([], in: window.view.typingAttributes,
                                         base: base)
        try window.key("y", code: 16)
        let first = try #require(WritingInlineFixture.runs(
            window.session.document
        ).first)
        #expect(first.text == "y" && first.traits.isEmpty)
    }
}
