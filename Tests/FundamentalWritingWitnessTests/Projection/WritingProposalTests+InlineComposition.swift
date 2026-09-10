import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test("expanded composition retains intervening source attributes")
    func inlineCompositionProposal() throws
    {
        let fixture = try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "A", traits: [.strong]),
                SemanticRun(text: "B", traits: [.emphasis]),
                SemanticRun(text: "CDE", traits: [.underline])
            ]))
        ], start: 2, end: 2)
        guard case let .editable(source) = fixture.state
        else
        {
            Issue.record("Expected an editable source fixture")
            return
        }
        let intent = DocumentTypingIntent(
            attributes: .direct(traits: [.inlineCode])
        )
        let state = try #require(EditableDocumentSnapshot(
            snapshot: source.snapshot, selection: source.selection,
            typingIntent: intent
        ))
        let projection = try #require(WritingProjection(.editable(state)))
        let first = try #require(WritingComposition.starting(
            at: NSRange(location: 2, length: 0), in: projection
        ))
        let marked = try #require(first.replacing(
            NSRange(location: 2, length: 0), with: "xy",
            selecting: NSRange(location: 2, length: 0)
        ))
        let expanded = try #require(marked.replacing(
            NSRange(location: 0, length: 1), with: "Z",
            selecting: NSRange(location: 1, length: 0)
        ))
        let result = try #require(expanded.input).projection
        #expect(expanded.text == "ZBxyCDE" && result.text == expanded.text)
        #expect(result.selection == NSRange(location: 1, length: 0))
        #expect(result.snapshot.typingIntent == intent)
        let runs = try WritingInlineFixture.runs(
            result.snapshot.snapshot.document
        )
        #expect(runs == [
            SemanticRun(text: "Z", traits: [.inlineCode]),
            SemanticRun(text: "B", traits: [.emphasis]),
            SemanticRun(text: "xy", traits: [.inlineCode]),
            SemanticRun(text: "CDE", traits: [.underline])
        ])
        #expect(projection.text == "ABCDE")
    }

    @Test("run comparison distinguishes spelling and traits but not partition")
    func inlineSequenceComparison() throws
    {
        let full = WritingRunSequence([SemanticRun(text: "e\u{301}😀",
                                                    traits: [.strong])])
        let split = WritingRunSequence([
            SemanticRun(text: "e", traits: [.strong]),
            SemanticRun(text: "\u{301}😀", traits: [.strong])
        ])
        #expect(full.matches(split))
        let composed = WritingRunSequence([
            SemanticRun(text: "é😀", traits: [.strong])
        ])
        let plain = WritingRunSequence([SemanticRun(text: full.text)])
        #expect(!full.matches(composed))
        #expect(!full.matches(plain))
        #expect(full.partition(NSRange(location: 1, length: 1)) != nil)
        #expect(full.partition(NSRange(location: 3, length: 0)) == nil)
    }
}
