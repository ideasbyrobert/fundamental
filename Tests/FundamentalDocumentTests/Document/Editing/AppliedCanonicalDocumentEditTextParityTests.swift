import Testing

@testable import FundamentalDocument

extension CanonicalDocumentEditTests
{
    @Test("text insertion matches its specialized result")
    func textInsertionMatchesSpecializedResult() throws
    {
        let source = try Self.textSource()
        let insertion = try AppliedSemanticTextEditTests.edit(at: 1)

        try Self.expectTextParity(
            .insertion(insertion),
            in: source
        )
    }

    @Test("text deletion matches its specialized result")
    func textDeletionMatchesSpecializedResult() throws
    {
        let source = try Self.textSource()
        let deletion = try AppliedSemanticTextDeletionTests.deletion(
            start: 1,
            end: 3
        )

        try Self.expectTextParity(
            .deletion(deletion),
            in: source
        )
    }

    @Test("text replacement matches its specialized result")
    func textReplacementMatchesSpecializedResult() throws
    {
        let source = try Self.textSource()
        let replacement = try AppliedSemanticTextReplacementTests.replacement(
            start: 1,
            end: 3
        )

        try Self.expectTextParity(
            .replacement(replacement),
            in: source
        )
    }
}
