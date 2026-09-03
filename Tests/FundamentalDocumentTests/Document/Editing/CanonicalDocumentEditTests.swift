import Testing

@testable import FundamentalDocument

@Suite("Canonical document editing")
struct CanonicalDocumentEditTests
{
    @Test("the closed vocabulary preserves all five effective edits")
    func closedVocabularyPreservesAllFiveEdits() throws
    {
        let values = try Self.values()
        let edits: [CanonicalDocumentEdit] = [
            .text(.insertion(values.insertion)),
            .text(.deletion(values.deletion)),
            .text(.replacement(values.replacement)),
            .split(values.split),
            .merge(values.merge)
        ]

        #expect(edits.map(Self.form) == [0, 1, 2, 3, 4])
        #expect(edits[0] == .text(.insertion(values.insertion)))
        #expect(edits[1] == .text(.deletion(values.deletion)))
        #expect(edits[2] == .text(.replacement(values.replacement)))
        #expect(edits[3] == .split(values.split))
        #expect(edits[4] == .merge(values.merge))
    }

    @Test("the applied boundary preserves equality and source value")
    func appliedBoundaryPreservesEqualityAndSource() throws
    {
        let source = try Self.textSource("AA")
        let original = source
        let firstEdit = try AppliedSemanticTextDeletionTests.deletion(
            start: 0,
            end: 1
        )
        let secondEdit = try AppliedSemanticTextDeletionTests.deletion(
            start: 1,
            end: 2
        )
        let first = try #require(AppliedCanonicalDocumentEdit(
            .text(.deletion(firstEdit)),
            in: source
        ))
        let equal = try #require(AppliedCanonicalDocumentEdit(
            .text(.deletion(firstEdit)),
            in: source
        ))
        let differentCaret = try #require(AppliedCanonicalDocumentEdit(
            .text(.deletion(secondEdit)),
            in: source
        ))

        let leftSource = try Self.textSource("AB")
        let rightSource = try Self.textSource("AC")
        let left = try #require(AppliedCanonicalDocumentEdit(
            .text(.deletion(firstEdit)),
            in: leftSource
        ))
        let right = try #require(AppliedCanonicalDocumentEdit(
            .text(.deletion(firstEdit)),
            in: rightSource
        ))

        Self.requireSendable(CanonicalDocumentEdit.self)
        Self.requireSendable(AppliedCanonicalDocumentEdit.self)
        #expect(first == equal)
        #expect(first.document == differentCaret.document)
        #expect(first.caret != differentCaret.caret)
        #expect(first != differentCaret)
        #expect(left.document != right.document)
        #expect(left.caret == right.caret)
        #expect(left != right)
        #expect(source == original)
    }
}
