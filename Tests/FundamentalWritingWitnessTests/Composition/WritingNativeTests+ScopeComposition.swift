import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("expanded composition retains scopes and exact destinations")
    func nativeScopeComposition() throws
    {
        let first = try WritingScopeFixture.run("A", form: 0, traits: [.strong])
        let kept = try WritingScopeFixture.run("B", form: 1,
                                              traits: [.emphasis])
        let last = try WritingScopeFixture.run("CDE", form: 2,
                                              traits: [.underline])
        let source = try WritingTestDocument(blocks: [.paragraph(
            SemanticParagraph(runs: [first, kept, last])
        )], start: 2, end: 2)
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state
        ))
        defer
        {
            window.close()
        }
        let target = try #require(SemanticLinkDestination(
            " https://example.invalid/é "
        ))
        let language = try #require(SemanticLanguageIdentifier(
            WritingScopeFixture.language
        ))
        let inserted = SemanticRunAttributes.scoped(traits: [.inlineCode],
            scopes: .linkAndLanguage(link: target, language: language))
        try WritingInlineFixture.choose(.emphasis, enabled: false, in: window)
        try WritingInlineFixture.choose(.inlineCode, in: window)
        try WritingScopeFixture.choose(.link(target), in: window)
        let before = window.storage
        window.mark("xy")
        window.mark("Z", replacing: NSRange(location: 0, length: 1))
        #expect(window.storage == before && window.view.hasMarkedText())
        #expect(window.view.string == "ZBxyCDE")
        let storage = try #require(window.view.textStorage)
        WritingScopeFixture.expect(1, in: storage.attributes(
            at: 1, effectiveRange: nil
        ))
        window.commit("Q")
        try window.expect("QBxyCDE", selection: NSRange(location: 1, length: 0))
        #expect(window.session.history.undo.count == 1)
        #expect(try WritingInlineFixture.runs(window.session.document) == [
            SemanticRun(text: "Q", attributes: inserted), kept,
            SemanticRun(text: "xy", attributes: inserted), last
        ])
        let after = window.session.document.content
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            source.state.snapshot.document.content)
        window.view.redoCanonicalEdit(nil)
        #expect(window.session.document.content == after)
        let native = window.view.typingAttributes[.link] as? String
        #expect(native?.utf16.elementsEqual(target.value.utf16) == true)
        try WritingWindowGeometry.expectVisibleCaret(window)
    }
}
