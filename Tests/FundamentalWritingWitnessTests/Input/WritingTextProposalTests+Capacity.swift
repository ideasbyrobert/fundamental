import Foundation
import Testing

@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test
    func replacementCapacityUsesRemovedAndInsertedUTF16Units() throws
    {
        let exact = String(repeating: "A", count: 65_536)
        let projection = try WritingTestDocument(exact).projection()
        let cases: [(Int, String, Bool)] = [
            (0, "X", false), (1, "X", true),
            (1, "😀", false), (2, "😀", true),
            (2, "\r", false), (2, "\n", false), (2, "\r\n", false)
        ]
        for (removed, replacement, admitted) in cases
        {
            let proposal = WritingTextProposal(
                ranges: [NSRange(location: 0, length: removed)],
                replacements: [replacement],
                in: projection
            )
            #expect((proposal != nil) == admitted)
        }
        let small = try WritingTestDocument("AB").projection()
        #expect(WritingTextProposal(
            ranges: [NSRange(location: 0, length: 2)],
            replacements: [exact],
            in: small
        ) != nil)
        #expect(Array(projection.text.utf16) == Array(exact.utf16))
    }
}
