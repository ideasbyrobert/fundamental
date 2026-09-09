import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test(arguments: CanonicalBlockStyle.allCases)
    func projectionPreservesHardLinesInsideTheirSemanticBlock(
        style: CanonicalBlockStyle
    ) throws
    {
        let text = "A\r\n\te\u{301}😀\n\r"
        let fixture = try WritingTestDocument(blocks: [
            style.semanticBlock(runs: [SemanticRun(text: text)]),
            CanonicalBlockStyle.body.semanticBlock(runs: [
                SemanticRun(text: "After")
            ])
        ])
        let projection = try fixture.projection()
        #expect(projection.text.utf16.elementsEqual(
            (text + "\r\nAfter").utf16
        ))
        #expect(projection.map.spans.count == 2)
        #expect(projection.map.spans[0].range.length == text.utf16.count)
        #expect(projection.map.spans[0].separatorLength == 2)
        let range = try #require(projection.range(NSRange(
            location: 3, length: text.utf16.count - 3
        )))
        #expect(range.start.blockID == range.end.blockID)
        #expect(range.start.utf16Offset.value == 3)
        #expect(range.end.utf16Offset.value == text.utf16.count)
    }

    @Test
    func proseReplacementNormalizesOnlyInsertedSourceLines() throws
    {
        let suffix = "\r\n\te\u{301}😀\r"
        let fixture = try WritingTestDocument(blocks: [
            CanonicalBlockStyle.title.semanticBlock(runs: [
                SemanticRun(text: "AB")
            ]),
            WritingCodeFixture.block("C" + suffix, tagged: true)
        ])
        let projection = try fixture.projection()
        let proposal = try #require(WritingTextProposal(
            ranges: [NSRange(location: 1, length: 3)],
            replacements: ["X\r\nY\rZ"], in: projection
        ))
        guard case let .applied(state) = DocumentSessionTransition(
            proposal.command, in: fixture.state
        )
        else
        {
            Issue.record("Expected a prose-led replacement")
            return
        }
        let blocks = state.snapshot.document.content.blocks
        #expect(blocks.map { CanonicalBlockStyle($0.block) } ==
            [.title, .body, .body])
        #expect(try #require(WritingProjection(state)).text.utf16
            .elementsEqual(("AX\nY\nZ" + suffix).utf16))
    }
}
