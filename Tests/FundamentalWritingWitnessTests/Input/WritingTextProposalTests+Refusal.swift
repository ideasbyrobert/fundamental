import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test
    func wrongCardinalityAndAttributeOnlyProposalsRefuse() throws
    {
        let projection = try WritingTestDocument("AB").projection()
        let range = NSRange(location: 0, length: 1)
        let replacements: [[String]?] = [nil, [], ["X", "Y"]]
        for replacement in replacements
        {
            #expect(WritingTextProposal(ranges: [range],
                                        replacements: replacement,
                                        in: projection) == nil)
        }
        for ranges in [[], [range, NSRange(location: 1, length: 1)]]
        {
            #expect(WritingTextProposal(ranges: ranges,
                                        replacements: ["X"],
                                        in: projection) == nil)
        }
    }

    @Test
    func invalidAndOverflowingNativeExtentsRefuse() throws
    {
        let projection = try WritingTestDocument("AB").projection()
        let invalid = [
            NSRange(location: -1, length: 0),
            NSRange(location: 0, length: -1),
            NSRange(location: NSNotFound, length: 0),
            NSRange(location: Int.max, length: 2),
            NSRange(location: 3, length: 0),
            NSRange(location: 1, length: 2)
        ]
        for range in invalid
        {
            #expect(WritingTextProposal(ranges: [range],
                                        replacements: ["X"],
                                        in: projection) == nil)
            #expect(WritingSelectionProposal(ranges: [range], in: projection)
                == nil)
        }
    }

    @Test
    func emptyCollapsedReplacementDoesNotInventAnEdit() throws
    {
        let projection = try WritingTestDocument("A").projection()
        #expect(WritingTextProposal(
            ranges: [NSRange(location: 0, length: 0)],
            replacements: [""],
            in: projection
        ) == nil)
        #expect(WritingTextProposal(
            ranges: [NSRange(location: 0, length: 1)],
            replacements: [""],
            in: projection
        ) != nil)
    }
}
