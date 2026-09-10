import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test("scalar input keeps actual source attributes within a grapheme")
    func inlineScalarInput() throws
    {
        let fixture = try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "\u{915}", traits: [.strong]),
                SemanticRun(text: "\u{93F}", traits: [.emphasis])
            ]))
        ], start: 2, end: 2)
        let projection = try fixture.projection()
        for replacement in ["", "\u{94D}"]
        {
            let proposal = try #require(WritingTextProposal(
                ranges: [NSRange(location: 1, length: 1)],
                replacements: [replacement], in: projection
            ))
            let result = try applied(proposal.command, to: fixture.state)
            let runs = try WritingInlineFixture.runs(
                result.snapshot.document
            )
            #expect(runs.first == SemanticRun(text: "\u{915}",
                                               traits: [.strong]))
            #expect(runs.count == (replacement.isEmpty ? 1 : 2))
            if !replacement.isEmpty
            {
                #expect(runs.last == SemanticRun(text: replacement,
                                                  traits: [.emphasis]))
            }
        }
    }
}
