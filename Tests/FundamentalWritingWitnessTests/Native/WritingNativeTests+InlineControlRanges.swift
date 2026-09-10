import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingNativeTests
{
    @Test("mixed Text choices apply once and toggle off across block roles",
          arguments: WritingInlineFixture.traits)
    func inlineControlsRange(_ trait: SemanticInlineTrait) throws
    {
        let source = try WritingTestDocument(blocks: [
            .heading(.title(TitleSemanticHeading(runs: [
                SemanticRun(text: "A", traits: [trait])
            ]))), .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "e\u{301}😀"),
                SemanticRun(text: "", traits: [.strong])
            ]))
        ])
        let window = try WritingTestWindow(session: DocumentSession(
            state: source.state
        ))
        defer
        {
            window.close()
        }
        window.select(0, window.view.string.utf16.count)
        let before = window.storage
        let roles = window.styles
        let selection = window.view.selectedRange()
        try window.expectInline(trait, .mixed)
        try window.chooseInline(trait)
        try window.expectInline(trait, .on)
        #expect(window.view.selectedRange() == selection)
        #expect(window.styles == roles)
        #expect(window.session.history.undo.count == 1)
        let after = window.session.document.content
        let runs = try WritingInlineFixture.runs(window.session.document)
        #expect(runs.filter { !$0.text.isEmpty }.allSatisfy
            { $0.traits.contains(trait) })
        #expect(runs.last == SemanticRun(text: "", traits: [.strong]))
        try window.chooseInline(trait, toolbar: false)
        try window.expectInline(trait, .off)
        #expect(window.session.history.undo.count == 2)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content == after)
        window.view.undoCanonicalEdit(nil)
        #expect(window.session.document.content ==
            before.state.snapshot.document.content)
        try window.expectInline(trait, .mixed)
        #expect(window.view.selectedRange() == selection)
    }
}
