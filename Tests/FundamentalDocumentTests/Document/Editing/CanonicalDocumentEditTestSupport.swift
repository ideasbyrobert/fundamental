import Testing

@testable import FundamentalDocument

extension CanonicalDocumentEditTests
{
    static func values() throws -> (
        insertion: SemanticTextInsertion,
        deletion: SemanticTextDeletion,
        replacement: SemanticTextReplacement,
        split: SemanticBlockSplit,
        merge: SemanticBlockMerge
    )
    {
        let text = try SemanticTextEditTests.values()
        let splitCandidate = try AppliedSemanticBlockSplitTests.request(at: 1)
        let mergeCandidate = try AppliedSemanticBlockMergeTests.request()
        let split = try #require(splitCandidate)
        let merge = try #require(mergeCandidate)
        return (
            text.insertion,
            text.deletion,
            text.replacement,
            split,
            merge
        )
    }

    static func form(_ edit: CanonicalDocumentEdit) -> Int
    {
        switch edit
        {
        case .text(.insertion):
            0
        case .text(.deletion):
            1
        case .text(.replacement):
            2
        case .split:
            3
        case .merge:
            4
        }
    }

    static func textSource(
        _ text: String = "ABCD"
    ) throws -> CanonicalDocument
    {
        try AppliedSemanticTextEditTests.document(blocks: [
            (2, AppliedSemanticTextEditTests.paragraph([
                SemanticRun(text: text)
            ]))
        ])
    }

    static func mergeSource() throws -> CanonicalDocument
    {
        try AppliedSemanticBlockMergeTests.document(blocks: [
            (2, AppliedSemanticTextEditTests.paragraph([
                SemanticRun(text: "AB")
            ])),
            (3, AppliedSemanticTextEditTests.paragraph([
                SemanticRun(text: "CD")
            ]))
        ])
    }

    static func requireSendable<T: Sendable>(_ type: T.Type)
    {
    }

    static func expectTextParity(
        _ edit: SemanticTextEdit,
        in source: CanonicalDocument
    ) throws
    {
        let expected = try #require(AppliedSemanticTextEdit(
            edit,
            in: source
        ))
        let actual = try #require(AppliedCanonicalDocumentEdit(
            .text(edit),
            in: source
        ))

        #expect(actual.document == expected.document)
        #expect(actual.caret == expected.caret)
    }
}
