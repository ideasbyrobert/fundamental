import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test(arguments: [false, true])
    func codeSeamGrowthAndShrinkageRespectExactNativeCapacity(endsCR: Bool)
        throws
    {
        let limit = WritingSurfacePolicy.maximumUTF16Units
        let source = String(repeating: "A", count: limit -
            (endsCR ? 4 : 2)) + (endsCR ? "\r" : "")
        let fixture = try WritingTestDocument(blocks: [
            WritingCodeFixture.block(source, tagged: true),
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "B")]))
        ])
        let projection = try fixture.projection()
        #expect(projection.map.utf16Count == limit)
        let examples = endsCR
            ? [(0, "Z", true), (0, "\n", true), (0, "ZZ", false),
               (1, "ZZ", true), (1, "ZZZ", false), (1, "", true),
               (0, "\r", false)]
            : [(1, "\r", false), (2, "\r", true), (0, "\r", false),
               (0, "", false), (1, "Z", true)]
        for (removed, replacement, admitted) in examples
        {
            let proposal = WritingTextProposal(
                ranges: [NSRange(location: source.utf16.count - removed,
                                  length: removed)],
                replacements: [replacement], in: projection
            )
            #expect((proposal != nil) == admitted)
            if let proposal
            {
                let successor = try applied(proposal.command,
                                            to: fixture.state)
                let native = try #require(WritingProjection(
                    .editable(successor)
                ))
                #expect(native.map.utf16Count <= limit)
                #expect(native.map.utf16Count == native.text.utf16.count)
            }
        }
        let overflowing = try WritingTestDocument(blocks: [
            WritingCodeFixture.block(source + "\r", tagged: true),
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "B")]))
        ])
        #expect(WritingProjection(overflowing.state) == nil)
    }
}
