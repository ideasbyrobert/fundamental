import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("native scoped typing Return and Unicode survive history",
          arguments: [0, 1, 2])
    func nativeScopeTyping(_ form: Int) throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.select(1)
        try WritingInlineFixture.choose(.strong, in: window)
        try WritingScopeFixture.choose(form, in: window)
        WritingScopeFixture.expect(form, in: window.view.typingAttributes)
        try window.key("x", code: 7)
        try window.key("\r", code: 36)
        window.commit("e\u{301}😀")
        try window.expect("Ax\ne\u{301}😀B", selection: NSRange(
            location: 7, length: 0
        ))
        let runs = try WritingInlineFixture.runs(window.session.document)
        let inserted = runs.filter { $0.text == "x" || $0.text == "e\u{301}😀" }
        #expect(inserted == [
            try WritingScopeFixture.run("x", form: form, traits: [.strong]),
            try WritingScopeFixture.run("e\u{301}😀", form: form,
                                         traits: [.strong])
        ])
        #expect(window.session.history.undo.count == 3)
        let after = window.session.document.content
        for _ in 0 ..< 3
        {
            window.view.undoCanonicalEdit(nil)
        }
        #expect(window.view.string == "AB")
        WritingScopeFixture.expect(form, in: window.view.typingAttributes)
        for _ in 0 ..< 3
        {
            window.view.redoCanonicalEdit(nil)
        }
        #expect(window.session.document.content == after)
        WritingScopeFixture.expect(form, in: window.view.typingAttributes)
        window.select(0)
        #expect(window.view.typingAttributes[.link] == nil)
        #expect(window.view.typingAttributes[.languageIdentifier] == nil)
        try WritingWindowGeometry.expectVisibleCaret(window)
    }
}
