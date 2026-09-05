import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @Test
    func projectionPreservesExactSpellingAndCanonicalRunBoundaries() throws
    {
        let fixtures: [[SemanticRun]] = [
            [], [SemanticRun(text: "")],
            ["", "e", "\u{301}", "😀", ""].map { SemanticRun(text: $0) }
        ]
        let expected: [[UInt16]] = [[], [], [0x65, 0x301, 0xD83D, 0xDE00]]
        for (runs, units) in zip(fixtures, expected)
        {
            let source = try WritingTestDocument(blocks: [
                .paragraph(SemanticParagraph(runs: runs))
            ])
            let projection = try source.projection()
            #expect(Array(projection.text.utf16) == units)
            #expect(projection.snapshot.snapshot == source.state.snapshot)
            guard case let .paragraph(paragraph) = projection.snapshot
                .snapshot.document.content.blocks[0].block
            else
            {
                Issue.record("Expected a paragraph")
                continue
            }
            #expect(paragraph.runs.count == runs.count)
            #expect(projection.selection == NSRange(location: 0, length: 0))
            #expect(sent(projection) == projection)
        }
    }

    @Test
    func nativeBoundsDoNotInventSelectionDirection() throws
    {
        let source = try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "ABCD")]))
        ], start: 3, end: 1)
        let projection = try source.projection()
        #expect(projection.selection == NSRange(location: 1, length: 2))
        #expect(projection.snapshot.selection.range.start.utf16Offset.value
            == 3)
        #expect(projection.snapshot.selection.range.end.utf16Offset.value == 1)
    }
}
