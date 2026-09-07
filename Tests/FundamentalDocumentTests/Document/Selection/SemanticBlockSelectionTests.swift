import Testing

@testable import FundamentalDocument

@Suite("Selections intersect complete semantic blocks")
struct SemanticBlockSelectionTests
{
    @Test("an exclusive final boundary does not format the following block")
    func exclusiveBoundary() throws
    {
        let source = try SemanticWritingTestDocument([.body, .body, .body])
        for reverse in [false, true]
        {
            let range = try reverse ? source.range((2, 0), (0, 2)) :
                source.range((0, 2), (2, 0))
            let selection = try #require(SemanticBlockSelection(
                range: range, in: source.document
            ))
            #expect(selection.indices == 0...1)
            let changed = try #require(AppliedSemanticBlockStyleChange(
                SemanticBlockStyleChange(range: range, style: .heading),
                in: source.document
            ))
            let styles = changed.content.blocks.map
            {
                CanonicalBlockStyle($0.block)
            }
            #expect(styles == [.heading, .heading, .body])
        }
    }

    @Test("a caret belongs to exactly its block even when empty")
    func collapsedBoundary() throws
    {
        let source = try SemanticWritingTestDocument(
            [.body, .numbered, .body], texts: ["A", "", "B"]
        )
        let selection = try #require(SemanticBlockSelection(
            range: source.range((1, 0), (1, 0)), in: source.document
        ))
        #expect(selection.indices == 1...1)
        #expect(selection.blocks == [source.document.content.blocks[1]])
    }
}
