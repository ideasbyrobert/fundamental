import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test
    func insertionKeepsTheDisplayedObservationAndExactPayload() throws
    {
        let source = try WritingTestDocument("A")
        let projection = try source.projection()
        let proposal = try #require(WritingTextProposal(
            ranges: [NSRange(location: 1, length: 0)],
            replacements: ["e\u{301}"],
            in: projection
        ))
        guard case let .edit(observation, .text(.insertion(insertion))) =
            proposal.command
        else
        {
            Issue.record("Expected an insertion command")
            return
        }
        #expect(observation == projection.observation)
        #expect(Array(insertion.insertion.text.utf16) == [0x65, 0x301])
        #expect(insertion.insertion.attributes == .direct(traits: []))
        #expect(insertion.point.utf16Offset.value == 1)
        let after = try applied(proposal.command, to: source.state)
        try expect(after, text: "Ae\u{301}", revision: 9, generation: 4)
        #expect(sent(proposal) == proposal)
    }

    @Test
    func scalarDeletionReachesTheCanonicalBoundary() throws
    {
        let source = try WritingTestDocument("\u{915}\u{93F}")
        let projection = try source.projection()
        let proposal = try #require(WritingTextProposal(
            ranges: [NSRange(location: 1, length: 1)],
            replacements: [""],
            in: projection
        ))
        guard case .edit(_, .text(.deletion)) = proposal.command
        else
        {
            Issue.record("Expected a deletion command")
            return
        }
        let after = try applied(proposal.command, to: source.state)
        try expect(after, text: "\u{915}", revision: 9, generation: 4)
        #expect(after.selection.range.start.utf16Offset.value == 1)
    }

    @Test
    func selectedReplacementPreservesUTF16AndPostEditCaret() throws
    {
        let source = try WritingTestDocument("ABCD")
        let projection = try source.projection()
        let proposal = try #require(WritingTextProposal(
            ranges: [NSRange(location: 1, length: 2)],
            replacements: ["😀"],
            in: projection
        ))
        guard case .edit(_, .text(.replacement)) = proposal.command
        else
        {
            Issue.record("Expected a replacement command")
            return
        }
        let after = try applied(proposal.command, to: source.state)
        try expect(after, text: "A😀D", revision: 9, generation: 4)
        #expect(after.selection.range.start.utf16Offset.value == 3)
        #expect(source.state.snapshot.document.revision.value == 8)
    }
}
