import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockStyleChangeTests
{
    @Test("removing lists preserves every exact prose payload and raw run")
    func removeLists() throws
    {
        let runs = try BlockRecordTestValue.runs()
        let prose = try BlockRecordTestValue.blocks().filter
        {
            EditableSemanticBlock($0)?.isProse == true
        }
        let lists = [SemanticListKind.bulleted, .numbered].map
        {
            SemanticBlock.listItem(SemanticListItem(kind: $0, runs: runs))
        }
        let source = try SemanticWritingTestDocument(blocks: prose + lists)
        let length = runs.reduce(0) { $0 + $1.text.utf16.count }
        let range = try source.range((prose.count + 1, length), (0, 0))
        let result = try #require(AppliedSemanticBlockStyleChange(
            SemanticBlockStyleChange(removingListsIn: range),
            in: source.document
        ))
        let body = SemanticBlock.paragraph(SemanticParagraph(runs: runs))
        #expect(result.content.blocks.map(\.block) == prose + [body, body])
        #expect(result.content.blocks.map(\.blockID) ==
            source.document.content.blocks.map(\.blockID))
        for block in result.content.blocks.suffix(2)
        {
            let actual = try #require(EditableSemanticBlock(block.block))
            #expect(actual.runs == runs)
            for (original, retained) in zip(runs, actual.runs)
            {
                #expect(Array(original.text.utf16) ==
                    Array(retained.text.utf16))
            }
        }
    }

    @Test("an empty list item changes without affecting the next block")
    func removeEmptyList() throws
    {
        let source = try SemanticWritingTestDocument(blocks: [
            .listItem(SemanticListItem(kind: .bulleted, runs: [])),
            .listItem(SemanticListItem(kind: .numbered,
                                       runs: [SemanticRun(text: "Next")]))
        ])
        let result = try #require(AppliedSemanticBlockStyleChange(
            SemanticBlockStyleChange(
                removingListsIn: source.range((0, 0), (0, 0))
            ),
            in: source.document
        ))
        #expect(result.content.blocks[0].block ==
            .paragraph(SemanticParagraph(runs: [])))
        #expect(result.content.blocks[1] == source.document.content.blocks[1])
    }

    @Test("a code or table between list items refuses the entire removal")
    func removeListsRefusesUnsupportedBlocks() throws
    {
        let unsupported = try BlockRecordTestValue.blocks().filter
        {
            EditableSemanticBlock($0)?.isProse != true
        }
        let item = CanonicalBlockStyle.bulleted.semanticBlock(
            runs: [SemanticRun(text: "A")]
        )
        for block in unsupported
        {
            let source = try SemanticWritingTestDocument(
                blocks: [item, block, item]
            )
            #expect(AppliedSemanticBlockStyleChange(
                SemanticBlockStyleChange(
                    removingListsIn: try source.range((0, 0), (2, 1))
                ),
                in: source.document
            ) == nil)
        }
    }
}
