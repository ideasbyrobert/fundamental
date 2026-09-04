import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutFragmentMaterializationTests
{
    @MainActor
    @Test("direct scoped Unicode preserves every rich native fact")
    func richUnicode() throws
    {
        let block = SemanticBlock.paragraph(SemanticParagraph(
            runs: try demandingRuns()
        ))
        let value = try product([block], width: 180)
        let result = try diagnostics(
            value,
            extents: value.index.extents
        )
        try expectExact(
            result,
            product: value,
            extents: value.index.extents
        )
        #expect(result.usage.glyphs > 0)
        #expect(result.usage.caretStops > 0)
        #expect(result.usage.sourceSlices > 0)
        #expect(result.usage.decorations > 0)
        #expect(result.usage.residentUTF16Units > 0)
    }
}
