import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

extension LayoutBlockMeasurementTests
{
    @MainActor
    @Test("measurements retain no rich layout value")
    func lightweightValueGraph() throws
    {
        let prose = SemanticBlock.paragraph(SemanticParagraph(runs: [
            LayoutFixture.direct("Prose")
        ]))
        let code = SemanticBlock.code(.plain(PlainSemanticCodeBlock(
            runs: [LayoutFixture.direct("Code")]
        )))
        let table = SemanticBlock.table(
            try LayoutFixture.table(captioned: true)
        )
        let values = try [prose, code, table].map
        {
            try product($0, width: 360).measurement
        }
        let tokens = values.reduce(into: Set<String>())
        {
            $0.formUnion(storedTypeTokens($1))
        }
        let forbidden: Set<String> = [
            "LayoutLine",
            "LayoutGrid",
            "LayoutGlyph",
            "LayoutGlyphRun",
            "LayoutCaretStop",
            "LayoutSourceSlice",
            "LayoutDecoration"
        ]
        #expect(tokens.isDisjoint(with: forbidden))
    }
}
