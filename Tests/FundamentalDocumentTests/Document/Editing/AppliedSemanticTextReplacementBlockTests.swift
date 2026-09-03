import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextReplacementTests
{
    @Test("every editable block form remains exact")
    func everyEditableBlockFormRemainsExact() throws
    {
        let replacement = SemanticRun(text: "X")
        for (source, expected) in try Self.blockForms(
            sourceRuns: [SemanticRun(text: "AB")],
            expectedRuns: [replacement]
        )
        {
            let document = try Self.document(blocks: [(2, source)])
            let candidate = try Self.apply(
                start: 0,
                end: 2,
                in: document
            )
            let result = try #require(candidate)

            #expect(result.document.content.firstBlock.block == expected)
        }
    }
}
