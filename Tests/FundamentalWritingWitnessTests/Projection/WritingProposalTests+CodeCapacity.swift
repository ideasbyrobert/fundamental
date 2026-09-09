import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test
    func codeSourceNewlinesDoNotConsumeSemanticBlockCapacity() throws
    {
        let source = try WritingTestDocument(blocks: [
            WritingCodeFixture.block("", tagged: true)
        ])
        let text = String(repeating: "\n",
                          count: WritingSurfacePolicy.maximumParagraphs + 1)
        let proposal = try #require(WritingTextProposal(
            ranges: [NSRange(location: 0, length: 0)], replacements: [text],
            in: source.projection()
        ))
        let after = try applied(proposal.command, to: source.state)
        #expect(after.snapshot.document.content.blocks.count == 1)
        try WritingCodeFixture.expect(after.snapshot.document.content
            .blocks[0].block, text: text, tagged: true)
    }

    @Test
    func codeCapacityCountsCRLFPairsWithoutNormalizingThem() throws
    {
        let exact = String(repeating: "A",
                           count: WritingSurfacePolicy.maximumUTF16Units)
        let source = try WritingTestDocument(blocks: [
            WritingCodeFixture.block(exact, tagged: false)
        ])
        let projection = try source.projection()
        for (removed, replacement, admitted) in [
            (1, "\r\n", false), (2, "\r\n", true),
            (1, "\n", true), (0, "\n", false),
            (1, "😀", false), (2, "😀", true)
        ]
        {
            #expect((WritingTextProposal(
                ranges: [NSRange(location: 0, length: removed)],
                replacements: [replacement], in: projection
            ) != nil) == admitted)
        }
        let overflow = try WritingTestDocument(blocks: [
            WritingCodeFixture.block(exact + "\r", tagged: false)
        ])
        #expect(WritingProjection(overflow.state) == nil)
    }
}
