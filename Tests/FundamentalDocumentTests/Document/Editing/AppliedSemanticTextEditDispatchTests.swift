import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextReplacementTests
{
    @Test("dispatch equals all three specialized transitions")
    func dispatchEqualsSpecializedTransitions() throws
    {
        let source = try Self.document(blocks: [
            (2, Self.paragraph([SemanticRun(text: "ABCD")]))
        ])
        let insertion = try AppliedSemanticTextEditTests.edit(
            at: 1
        )
        let deletion = try AppliedSemanticTextDeletionTests.deletion(
            start: 1,
            end: 3
        )
        let replacement = try Self.replacement(
            start: 1,
            end: 3
        )
        let cases: [(SemanticTextEdit, AppliedSemanticTextEdit?)] = [
            (.insertion(insertion), AppliedSemanticTextEdit(
                insertion,
                in: source
            )),
            (.deletion(deletion), AppliedSemanticTextEdit(
                deletion,
                in: source
            )),
            (.replacement(replacement), AppliedSemanticTextEdit(
                replacement,
                in: source
            ))
        ]

        for (edit, specialized) in cases
        {
            #expect(AppliedSemanticTextEdit(edit, in: source) == specialized)
        }
    }
}
