import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("marked text cannot import foreign links or language scopes",
          arguments: [CanonicalBlockStyle.body, .monostyled])
    func nativeScopeMarkedInput(_ style: CanonicalBlockStyle) throws
    {
        let window = try WritingTestWindow(styles: [style], texts: ["AB"])
        defer
        {
            window.close()
        }
        window.select(1)
        try WritingInlineFixture.choose(.strong, in: window)
        try WritingScopeFixture.choose(2, in: window)
        let before = window.storage
        let text = "e\u{301}\r\n😀"
        let marked = NSAttributedString(string: text, attributes: [
            .link: "https://foreign.invalid", .languageIdentifier: "zz",
            .font: NSFont.systemFont(ofSize: 88), .foregroundColor: NSColor.red
        ])
        window.view.setMarkedText(marked, selectedRange: NSRange(
            location: text.utf16.count, length: 0
        ), replacementRange: NSRange(location: NSNotFound, length: 0))
        #expect(window.view.hasMarkedText() && window.storage == before)
        let storage = try #require(window.view.textStorage)
        WritingScopeFixture.expect(2, in: storage.attributes(
            at: 1, effectiveRange: nil
        ))
        window.commit(text)
        let expected = style == .body ? "Ae\u{301}\n😀B" : "A" + text + "B"
        #expect(window.view.string.utf16.elementsEqual(expected.utf16))
        #expect(window.session.history.undo.count == 1)
        let attributes = try WritingScopeFixture.run("", form: 2,
            traits: [.strong]).attributes
        let inserted = try WritingInlineFixture.runs(window.session.document)
            .filter { $0.text != "A" && $0.text != "B" && !$0.text.isEmpty }
        #expect(!inserted.isEmpty)
        #expect(inserted.allSatisfy { $0.attributes == attributes })
        WritingScopeFixture.expect(2, in: window.view.typingAttributes)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            before.state.snapshot.document.content)
    }
}
