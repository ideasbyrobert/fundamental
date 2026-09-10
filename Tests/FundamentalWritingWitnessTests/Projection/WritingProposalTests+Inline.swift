import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test("ordinary native proposals inherit exact source formatting")
    func inlineProposals() throws
    {
        for trait in WritingInlineFixture.traits
        {
            let fixture = try WritingTestDocument(blocks: [
                .paragraph(SemanticParagraph(runs: [
                    SemanticRun(text: "AB", traits: [trait])
                ]))
            ], start: 1, end: 1)
            for text in ["X", "X\r\nY"]
            {
                let proposal = try #require(WritingTextProposal(
                    ranges: [NSRange(location: 1, length: 0)],
                    replacements: [text], in: fixture.projection()
                ))
                guard case let .applied(state) = DocumentSessionTransition(
                    proposal.command, in: fixture.state
                )
                else
                {
                    Issue.record("Expected formatted native input")
                    return
                }
                let runs = try WritingInlineFixture.runs(
                    state.snapshot.document
                )
                #expect(runs.allSatisfy { $0.traits == [trait] })
                let expected = text.replacingOccurrences(of: "\r\n", with: "\n")
                #expect(try #require(WritingProjection(state)).text ==
                    "A" + expected + "B")
            }
        }
    }

    @Test("prose newline normalization preserves run attributes across CRLF")
    func inlineParagraphInput() throws
    {
        let runs = [SemanticRun(text: "A\r", traits: [.strong]),
                    SemanticRun(text: "\nB\rC\n", traits: [.emphasis])]
        let body = WritingParagraphInput(runs, sourceLines: false).paragraphs
        let spelling = body.map { $0.runs.map(\.text).joined() }
        #expect(spelling == ["A", "B", "C", ""])
        #expect(body[0].runs == [SemanticRun(text: "A", traits: [.strong])])
        for index in [1, 2]
        {
            #expect(body[index].runs[0].traits == [.emphasis])
        }
        #expect(body[3].runs.isEmpty)
        let code = WritingParagraphInput(runs, sourceLines: true).paragraphs
        #expect(code == [SemanticParagraph(runs: runs)])
    }
}
