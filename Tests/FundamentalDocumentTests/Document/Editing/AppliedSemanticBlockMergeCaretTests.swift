import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockMergeTests
{
    @Test("an ordinary former seam remains the exact caret")
    func ordinaryFormerSeamRemainsExactCaret() throws
    {
        let result = try Self.merge(
            Self.paragraph([SemanticRun(text: "AB")]),
            Self.paragraph([SemanticRun(text: "CD")])
        )

        #expect(result.caret.point.utf16Offset.value == 2)
        let resolved = try #require(ResolvedDocumentPoint(
            result.caret.point,
            in: result.document
        ))
        #expect(result.caret == resolved)
    }

    @Test("preceding affinity repairs recomposed Unicode seams")
    func precedingAffinityRepairsRecomposedUnicodeSeams() throws
    {
        let examples = [
            ("e", "\u{301}X", 0),
            ("\u{1F1E6}", "\u{1F1F2}\u{1F1FA}", 0)
        ]
        for example in examples
        {
            let result = try Self.merge(
                Self.paragraph([SemanticRun(text: example.0)]),
                Self.paragraph([SemanticRun(text: example.1)])
            )
            let actual = try Self.runs(in: result).map(\.text).joined()

            #expect(Self.scalarValues(actual) == Self.scalarValues(
                example.0 + example.1
            ))
            #expect(result.caret.point.utf16Offset.value == example.2)
        }
    }
}
