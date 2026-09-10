import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("marked clauses retain feedback without importing source appearance",
          arguments: [CanonicalBlockStyle.body, .monostyled])
    func nativeInlineMarkedInput(_ style: CanonicalBlockStyle) throws
    {
        let window = try WritingTestWindow(styles: [style], texts: ["AB"])
        defer
        {
            window.close()
        }
        window.select(1)
        try WritingInlineFixture.choose(.strong, in: window)
        let before = window.storage
        let text = "e\u{301}\r\n😀"
        let marked = NSAttributedString(string: text, attributes: [
            .font: NSFont.systemFont(ofSize: 88), .foregroundColor: NSColor.red,
            .markedClauseSegment: 3,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        window.view.setMarkedText(marked, selectedRange: NSRange(
            location: text.utf16.count, length: 0
        ), replacementRange: NSRange(location: NSNotFound, length: 0))
        #expect(window.view.hasMarkedText() && window.storage == before)
        let storage = try #require(window.view.textStorage)
        let font = try #require(storage.attribute(
            .font, at: 1, effectiveRange: nil
        ) as? NSFont)
        #expect(font.pointSize == (style == .body ? 20 : 18))
        #expect(font.fontDescriptor.symbolicTraits.contains(.bold))
        #expect(window.view.validAttributesForMarkedText().contains(
            .markedClauseSegment
        ))
        #expect(storage.attribute(.markedClauseSegment, at: 1,
                                   effectiveRange: nil) == nil)
        #expect(storage.attribute(.foregroundColor, at: 1,
                                   effectiveRange: nil) as? NSColor != .red)
        try WritingWindowGeometry.expectVisibleCaret(window)
        let bitmap = try WritingWindowCapture.capture(window)
        try WritingWindowCapture.export(bitmap,
            name: "inline-marked-" + style.rawValue)
        window.commit(text)
        let expected = style == .body ? "Ae\u{301}\n😀B" : "A" + text + "B"
        #expect(window.view.string.utf16.elementsEqual(expected.utf16))
        #expect(window.session.history.undo.count == 1)
        let inserted = try WritingInlineFixture.runs(window.session.document)
            .filter { $0.text != "A" && $0.text != "B" && !$0.text.isEmpty }
        #expect(!inserted.isEmpty)
        #expect(inserted.allSatisfy { $0.traits == [.strong] })
        #expect(storage.attribute(.markedClauseSegment, at: 1,
                                   effectiveRange: nil) == nil)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            before.state.snapshot.document.content)
    }
}
