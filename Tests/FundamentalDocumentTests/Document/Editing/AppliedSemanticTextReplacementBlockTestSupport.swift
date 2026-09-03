import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextReplacementTests
{
    static func document(
        revision: UInt64 = 8,
        blocks: [(UInt8, SemanticBlock)]
    ) throws -> CanonicalDocument
    {
        try AppliedSemanticTextDeletionTests.document(
            revision: revision,
            blocks: blocks
        )
    }

    static func paragraph(_ runs: [SemanticRun]) -> SemanticBlock
    {
        AppliedSemanticTextEditTests.paragraph(runs)
    }

    static func title(_ runs: [SemanticRun]) -> SemanticBlock
    {
        AppliedSemanticTextEditTests.title(runs)
    }

    static func plainCode(_ runs: [SemanticRun]) -> SemanticBlock
    {
        AppliedSemanticTextEditTests.plainCode(runs)
    }

    static func taggedCode(
        _ runs: [SemanticRun]
    ) throws -> SemanticBlock
    {
        try AppliedSemanticTextEditTests.taggedCode(runs)
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
