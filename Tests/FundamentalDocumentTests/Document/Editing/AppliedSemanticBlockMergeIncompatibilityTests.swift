import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockMergeTests
{
    @Test("every unequal form pair refuses atomically")
    func everyUnequalFormPairRefusesAtomically() throws
    {
        let run = [SemanticRun(text: "A")]
        var forms = [
            Self.paragraph(run),
            Self.title(run)
        ]
        forms += SemanticHeadingLevel.allCases.map
        {
            Self.section(run, level: $0)
        }
        forms += try [
            Self.plainCode(run),
            Self.taggedCode(run, language: "swift"),
            Self.taggedCode(run, language: "hy")
        ]

        for leadingIndex in forms.indices
        {
            for trailingIndex in forms.indices where
                trailingIndex != leadingIndex
            {
                let source = try Self.document(blocks: [
                    (2, forms[leadingIndex]),
                    (3, forms[trailingIndex])
                ])
                let original = source

                #expect(try Self.apply(in: source) == nil)
                #expect(source == original)
            }
        }
    }

    @Test("reversed and nonadjacent block orders refuse")
    func reversedAndNonadjacentOrdersRefuse() throws
    {
        let block = Self.paragraph([SemanticRun(text: "A")])
        let source = try Self.document(blocks: [
            (2, block), (3, block), (4, block)
        ])
        let original = source

        #expect(try Self.apply(
            leadingMarker: 3,
            trailingMarker: 2,
            in: source
        ) == nil)
        #expect(try Self.apply(
            leadingMarker: 2,
            trailingMarker: 4,
            in: source
        ) == nil)
        #expect(source == original)
    }
}
