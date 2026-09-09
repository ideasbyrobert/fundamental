import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test
    func mixedReplacementCountsTheResultingCRSeam() throws
    {
        let capacity = WritingSurfacePolicy.maximumUTF16Units
        let count = capacity - 3
        let fixture = try WritingTestDocument(blocks: [
            WritingCodeFixture.block(String(repeating: "A", count: count),
                                     tagged: false),
            .paragraph(SemanticParagraph(runs: [])),
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "B")]))
        ])
        let projection = try fixture.projection()
        let range = NSRange(location: count - 1, length: 2)
        let exact = try #require(WritingTextProposal(
            ranges: [range], replacements: ["\r"], in: projection
        ))
        guard case let .applied(state) = DocumentSessionTransition(
            exact.command, in: fixture.state
        )
        else
        {
            Issue.record("Expected exact mixed-replacement capacity")
            return
        }
        let result = try #require(WritingProjection(state))
        #expect(result.map.utf16Count == capacity)
        #expect(result.map.spans.count == 2)
        #expect(result.map.spans[0].separatorLength == 2)
        #expect(WritingTextProposal(ranges: [range], replacements: ["\r\r"],
            in: projection) == nil)
    }

    @Test(arguments: [false, true])
    func mixedReplacementCountsParagraphsFromTheLeadingRole(code: Bool)
        throws
    {
        let maximum = WritingSurfacePolicy.maximumParagraphs
        let first: CanonicalBlockStyle = code ? .monostyled : .body
        let last: CanonicalBlockStyle = code ? .body : .monostyled
        let fixture = try WritingTestDocument(blocks: [
            first.semanticBlock(runs: [SemanticRun(text: "A")]),
            last.semanticBlock(runs: [SemanticRun(text: "B")])
        ])
        let projection = try fixture.projection()
        let range = NSRange(location: 0, length: 3)
        let exact = try #require(WritingTextProposal(
            ranges: [range], replacements: [String(repeating: "\n",
                count: maximum - 1)], in: projection
        ))
        guard case let .applied(state) = DocumentSessionTransition(
            exact.command, in: fixture.state
        )
        else
        {
            Issue.record("Expected bounded mixed replacement")
            return
        }
        #expect(state.snapshot.document.content.blocks.count ==
            (code ? 1 : maximum))
        let extra = WritingTextProposal(ranges: [range],
            replacements: [String(repeating: "\n", count: maximum)],
            in: projection)
        #expect((extra != nil) == code)
    }
}
