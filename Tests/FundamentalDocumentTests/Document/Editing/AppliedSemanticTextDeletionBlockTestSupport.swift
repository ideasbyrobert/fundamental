import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextDeletionTests
{
    static func paragraph(_ runs: [SemanticRun]) -> SemanticBlock
    {
        AppliedSemanticTextEditTests.paragraph(runs)
    }

    static func plainCode(_ runs: [SemanticRun]) -> SemanticBlock
    {
        AppliedSemanticTextEditTests.plainCode(runs)
    }

    static func blockForms(
        sourceRuns: [SemanticRun],
        expectedRuns: [SemanticRun]
    ) throws -> [(SemanticBlock, SemanticBlock)]
    {
        try AppliedSemanticTextEditTests.blockForms(
            sourceRuns: sourceRuns,
            expectedRuns: expectedRuns
        )
    }

    static func runs(
        in result: AppliedSemanticTextEdit,
        at index: Int = 0
    ) throws -> [SemanticRun]
    {
        try AppliedSemanticTextEditTests.runs(
            in: result,
            at: index
        )
    }

    static func text(
        in result: AppliedSemanticTextEdit
    ) throws -> String
    {
        try AppliedSemanticTextEditTests.text(in: result)
    }
}
