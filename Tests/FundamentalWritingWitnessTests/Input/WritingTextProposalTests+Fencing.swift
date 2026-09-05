import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test
    func olderDisplayedObservationCannotRetargetNewerState() throws
    {
        let source = try WritingTestDocument("ABCD")
        let projection = try source.projection()
        let selection = try #require(WritingSelectionProposal(
            ranges: [NSRange(location: 1, length: 1)],
            in: projection
        ))
        let insertion = try #require(WritingTextProposal(
            ranges: [NSRange(location: 0, length: 0)],
            replacements: ["X"],
            in: projection
        ))
        let commands = [selection.command, insertion.command]
        for change in commands
        {
            let newer = try applied(change, to: source.state)
            let late = try #require(WritingTextProposal(
                ranges: [NSRange(location: 2, length: 0)],
                replacements: ["Y"],
                in: projection
            ))
            #expect(DocumentSessionTransition(late.command,
                                              in: .editable(newer)) ==
                .refused(.staleObservation))
            let current = try #require(WritingProjection(.editable(newer)))
            #expect(current.observation != projection.observation)
            #expect(Array(projection.text.utf16) == [65, 66, 67, 68])
        }
    }
}
