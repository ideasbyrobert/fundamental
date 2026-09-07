import Testing

@testable import FundamentalDocument

@Suite("Block formatting preserves semantic runs")
struct AppliedSemanticBlockStyleChangeTests
{
    @Test("every prose role preserves empty scoped styled and raw Unicode runs")
    func preservedRuns() throws
    {
        let runs = try BlockRecordTestValue.runs()
        let styles = CanonicalBlockStyle.allCases.filter { $0 != .monostyled }
        for original in styles
        {
            let source = try DocumentRecordTestValue.document(blocks: [
                original.semanticBlock(runs: runs)
            ])
            let point = DocumentPoint(
                documentID: source.documentID, revision: source.revision,
                blockID: source.content.blocks[0].blockID,
                utf16Offset: try #require(DocumentUTF16Offset(0))
            )
            for target in styles
            {
                let result = try #require(AppliedSemanticBlockStyleChange(
                    SemanticBlockStyleChange(
                        range: .caret(at: point), style: target
                    ),
                    in: source
                ))
                let block = result.content.blocks[0]
                #expect(block.blockID == source.content.blocks[0].blockID)
                #expect(block.block == target.semanticBlock(runs: runs))
                let actual = try #require(EditableSemanticBlock(block.block))
                #expect(actual.runs == runs)
                for (first, last) in zip(runs, actual.runs)
                {
                    #expect(Array(first.text.utf16) == Array(last.text.utf16))
                }
            }
        }
    }
}
