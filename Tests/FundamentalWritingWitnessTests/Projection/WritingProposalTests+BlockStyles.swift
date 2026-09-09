import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test
    func nativeCodeChoiceRetainsExistingTagAndJoinsSelectedProse() throws
    {
        let fixture = try WritingCodeFixture.document("A\r\nB", tagged: true)
        let projection = try fixture.projection()
        let codeRange = try #require(projection.range(NSRange(location: 7,
                                                              length: 0)))
        let same = try #require(WritingBlockStyleProposal(
            style: .monostyled, range: codeRange, in: projection
        ))
        #expect(DocumentSessionTransition(same.command, in: fixture.state) ==
            .unchanged)
        let all = try #require(projection.range(NSRange(location: 0,
            length: projection.map.utf16Count)))
        let joined = try #require(WritingBlockStyleProposal(
            style: .monostyled, range: all, in: projection
        ))
        let result = try applied(joined.command, to: fixture.state)
        let blocks = result.snapshot.document.content.blocks
        #expect(blocks.count == 1)
        try WritingCodeFixture.expect(blocks[0].block,
            text: "Before\nA\r\nB\nAfter", tagged: false)
        #expect(blocks[0].blockID ==
            fixture.state.snapshot.document.content.blocks[0].blockID)
    }

    @Test
    func nativeProseChoiceUsesCanonicalSourceLineBoundaries() throws
    {
        let fixture = try WritingCodeFixture.document("A\r\nB\r", tagged: true)
        let projection = try fixture.projection()
        let range = try #require(projection.range(NSRange(location: 7,
                                                          length: 0)))
        let proposal = try #require(WritingBlockStyleProposal(
            style: .heading, range: range, in: projection
        ))
        let result = try applied(proposal.command, to: fixture.state)
        let blocks = result.snapshot.document.content.blocks
        #expect(blocks.map { CanonicalBlockStyle($0.block) } ==
            [.body, .heading, .heading, .heading, .body])
        let next = try #require(WritingProjection(.editable(result)))
        #expect(next.text == "Before\nA\nB\n\nAfter")
        #expect(blocks[0] == fixture.state.snapshot.document.content.blocks[0])
        #expect(blocks[4] == fixture.state.snapshot.document.content.blocks[2])
        #expect(Set(blocks.map(\.blockID)).count == 5)
    }

    @Test
    func nativeProseChoiceRefusesExcessResultingParagraphs() throws
    {
        for admitted in [true, false]
        {
            let count = WritingSurfacePolicy.maximumParagraphs -
                (admitted ? 1 : 0)
            let fixture = try WritingTestDocument(blocks: [
                WritingCodeFixture.block(String(repeating: "\n", count: count),
                                          tagged: false)
            ])
            let projection = try fixture.projection()
            let proposal = WritingBlockStyleProposal(style: .body,
                range: projection.snapshot.selection.range, in: projection)
            #expect((proposal != nil) == admitted)
            if let proposal
            {
                let result = try applied(proposal.command, to: fixture.state)
                #expect(WritingProjection(.editable(result))?.map.spans.count ==
                    WritingSurfacePolicy.maximumParagraphs)
            }
        }
    }
}
