import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @MainActor
    @Test(arguments: [false, true], ["\n", "\r\n", "\r", "\t\n\ne\u{301} 😀"])
    func codeInsertionPreservesSourceLinesAndOneBlock(
        tagged: Bool, replacement: String
    ) throws
    {
        let fixture = try WritingCodeFixture.document("AB", tagged: tagged)
        let projection = try fixture.projection()
        let before = fixture.state.snapshot.document
        let offset = projection.map.spans[1].range.location + 1
        let proposal = try #require(WritingTextProposal(
            ranges: [NSRange(location: offset, length: 0)],
            replacements: [replacement], in: projection
        ))
        let session = DocumentSession(state: fixture.state)
        guard case .applied = session.submit(proposal.command)
        else
        {
            Issue.record("Expected a canonical source-line insertion")
            return
        }
        let after = session.document.content.blocks
        #expect(after.map(\.blockID) == before.content.blocks.map(\.blockID))
        #expect(after.first == before.content.blocks.first)
        #expect(after.last == before.content.blocks.last)
        try WritingCodeFixture.expect(after[1].block,
            text: "A" + replacement + "B", tagged: tagged)
        #expect(session.history.undo.count == 1)
        let updated = try #require(WritingProjection(session.state))
        #expect(updated.selection == NSRange(
            location: offset + replacement.utf16.count, length: 0
        ))
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .undo
        ))
        #expect(session.document.content == before.content)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .redo
        ))
        #expect(session.document.content.blocks == after)
    }

    @Test(arguments: [false, true])
    func codeBoundaryReplacementRefusesBeforeNativeMutation(tagged: Bool)
        throws
    {
        let fixture = try WritingCodeFixture.document("A\nB", tagged: tagged)
        let projection = try fixture.projection()
        let code = projection.map.spans[1].range
        for range in [NSRange(location: code.location - 1, length: 1),
                      NSRange(location: NSMaxRange(code), length: 1),
                      NSRange(location: 0, length: projection.map.utf16Count)]
        {
            for replacement in ["", "X", "\n"]
            {
                #expect(WritingTextProposal(ranges: [range],
                    replacements: [replacement], in: projection) == nil)
            }
        }
        #expect(try fixture.projection() == projection)
    }
}
