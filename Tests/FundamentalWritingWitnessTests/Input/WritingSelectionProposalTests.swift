import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test
    func selectionPreservesObservationAndDefersCanonicalBoundaryLaw() throws
    {
        let source = try WritingTestDocument("ABCD")
        let projection = try source.projection()
        let range = NSRange(location: 1, length: 2)
        let proposal = try #require(WritingSelectionProposal(
            ranges: [range], in: projection
        ))
        guard case let .select(observation, selection) = proposal.command
        else
        {
            Issue.record("Expected a selection command")
            return
        }
        #expect(observation == projection.observation)
        #expect(selection.range.start.utf16Offset.value == 1)
        #expect(selection.range.end.utf16Offset.value == 3)
        let after = try applied(proposal.command, to: source.state)
        try expect(after, text: "ABCD", revision: 8, generation: 4)
        #expect(WritingSelectionProposal(ranges: [], in: projection) == nil)
        #expect(WritingSelectionProposal(ranges: [range, range],
                                         in: projection) == nil)
        let scalarSource = try WritingTestDocument("😀A")
        let scalarProjection = try scalarSource.projection()
        let scalar = try #require(WritingSelectionProposal(
            ranges: [NSRange(location: 1, length: 0)],
            in: scalarProjection
        ))
        #expect(DocumentSessionTransition(scalar.command,
                                          in: scalarSource.state) ==
            .refused(.invalidCommand))
        #expect(sent(proposal) == proposal)
    }
}
