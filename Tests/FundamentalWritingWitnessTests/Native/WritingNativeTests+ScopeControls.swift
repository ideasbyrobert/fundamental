import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("inline controls retain scopes in selected text and typing intent",
          arguments: [0, 1, 2])
    func nativeScopeControls(_ form: Int) throws
    {
        let text = "Ae\u{301}😀Z"
        let source = try WritingTestDocument(blocks: [.paragraph(
            SemanticParagraph(runs: [WritingScopeFixture.run(text, form: form)])
        )])
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state, initiallySaved: true
        ))
        defer
        {
            window.close()
        }
        window.select(0, text.utf16.count)
        for trait in WritingInlineFixture.traits
        {
            try window.expectInline(trait, .off)
            try window.chooseInline(trait)
            try window.expectInline(trait, .on)
            #expect(try WritingInlineFixture.runs(window.session.document) == [
                try WritingScopeFixture.run(text, form: form, traits: [trait])
            ])
            #expect(window.view.selectedRange().length == text.utf16.count)
            window.view.undoCanonicalEdit(nil)
            #expect(window.session.document.content ==
                source.state.snapshot.document.content)
            #expect(!window.session.isDirty)
        }
        window.select(1)
        try window.chooseInline(.strong)
        try window.expectInline(.strong, .on)
        WritingScopeFixture.expect(form, in: window.view.typingAttributes)
        #expect(!window.session.isDirty)
        try window.key("x", code: 7)
        let inserted = try #require(WritingInlineFixture.runs(
            window.session.document
        ).first { $0.text == "x" })
        #expect(try inserted == WritingScopeFixture.run(
            "x", form: form, traits: [.strong]
        ))
        window.view.undoCanonicalEdit(nil)
        #expect(!window.session.isDirty)
        WritingScopeFixture.expect(form, in: window.view.typingAttributes)
    }
}
