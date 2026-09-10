import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("expanded native composition preserves intervening formatted runs")
    func nativeInlineComposition() throws
    {
        let source = try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "A", traits: [.strong]),
                SemanticRun(text: "B", traits: [.emphasis]),
                SemanticRun(text: "CDE", traits: [.underline])
            ]))
        ], start: 2, end: 2)
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state
        ))
        defer
        {
            window.close()
        }
        try WritingInlineFixture.choose(.emphasis, enabled: false, in: window)
        try WritingInlineFixture.choose(.inlineCode, in: window)
        let before = window.storage
        window.mark("xy")
        window.mark("Z", replacing: NSRange(location: 0, length: 1))
        #expect(window.storage == before && window.view.hasMarkedText())
        #expect(window.view.string == "ZBxyCDE")
        let storage = try #require(window.view.textStorage)
        let kept = try #require(storage.attribute(
            .font, at: 1, effectiveRange: nil
        ) as? NSFont)
        #expect(kept.fontDescriptor.symbolicTraits.contains(.italic))
        window.commit("Q")
        try window.expect("QBxyCDE", selection: NSRange(location: 1, length: 0))
        #expect(window.session.history.undo.count == 1)
        #expect(try WritingInlineFixture.runs(window.session.document) == [
            SemanticRun(text: "Q", traits: [.inlineCode]),
            SemanticRun(text: "B", traits: [.emphasis]),
            SemanticRun(text: "xy", traits: [.inlineCode]),
            SemanticRun(text: "CDE", traits: [.underline])
        ])
        let base = try #require(WritingTypography.body[.font] as? NSFont)
        try WritingInlineFixture.expect([.inlineCode],
            in: window.view.typingAttributes, base: base)
        let after = window.session.document.content
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            source.state.snapshot.document.content)
        window.view.redoCanonicalEdit(nil)
        #expect(window.session.document.content == after)
        try WritingInlineFixture.expect([.inlineCode],
            in: window.view.typingAttributes, base: base)
    }
}
