import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("repeated conversion stays provisional and commits one undo entry")
    func conversion() throws
    {
        let window = try WritingTestWindow(session: DocumentSession(
            state: WritingTestDocument("AB").state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        window.select(1)
        let before = window.storage
        for text in ["k", "kanji", "かんじ"]
        {
            window.mark(text)
            #expect(window.storage == before)
            #expect(!window.session.isDirty)
            #expect(window.view.string == "A" + text + "B")
            #expect(window.view.hasMarkedText())
            #expect(window.view.markedRange() == NSRange(
                location: 1, length: text.utf16.count
            ))
        }
        window.commit("漢字")
        try window.expect("A漢字B", selection: NSRange(location: 3, length: 0))
        #expect(!window.view.hasMarkedText())
        #expect(window.session.history.undo.count == 1)
        #expect(window.session.document.revision.value ==
            before.state.snapshot.document.revision.value + 1)
        #expect(window.session.isDirty)
        window.view.undoCanonicalEdit(nil)
        try window.expect("AB", selection: NSRange(location: 1, length: 0))
        #expect(!window.session.isDirty)
        window.view.redoCanonicalEdit(nil)
        try window.expect("A漢字B", selection: NSRange(location: 3, length: 0))
    }

    @Test("attributed preedit retains exact accepted Unicode as plain content")
    func attributedUnicode() throws
    {
        let window = try WritingTestWindow("AB")
        defer
        {
            window.close()
        }
        window.select(1)
        let text = "e\u{301} 👩🏽‍💻"
        let value = NSAttributedString(string: text, attributes: [
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ])
        window.view.setMarkedText(value, selectedRange: NSRange(
            location: text.utf16.count, length: 0
        ), replacementRange: NSRange(location: NSNotFound, length: 0))
        #expect(window.view.hasMarkedText())
        window.view.unmarkText()
        try window.expect("A" + text + "B", selection: NSRange(
            location: 1 + text.utf16.count, length: 0
        ))
        #expect(window.session.history.undo.count == 1)
        #expect(!window.view.hasMarkedText())
    }
}
