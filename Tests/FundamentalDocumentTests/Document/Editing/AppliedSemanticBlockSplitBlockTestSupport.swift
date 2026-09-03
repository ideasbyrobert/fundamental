import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockSplitTests
{
    static func paragraph(_ runs: [SemanticRun]) -> SemanticBlock
    {
        AppliedSemanticTextEditTests.paragraph(runs)
    }

    static func title(_ runs: [SemanticRun]) -> SemanticBlock
    {
        AppliedSemanticTextEditTests.title(runs)
    }

    static func section(
        _ runs: [SemanticRun],
        level: SemanticHeadingLevel
    ) -> SemanticBlock
    {
        AppliedSemanticTextEditTests.section(runs, level: level)
    }

    static func plainCode(_ runs: [SemanticRun]) -> SemanticBlock
    {
        AppliedSemanticTextEditTests.plainCode(runs)
    }

    static func taggedCode(
        _ runs: [SemanticRun],
        language: String = "swift"
    ) throws -> SemanticBlock
    {
        let identifier = try #require(
            SemanticCodeLanguageIdentifier(language)
        )
        return .code(.languageTagged(LanguageTaggedSemanticCodeBlock(
            runs: runs,
            language: identifier
        )))
    }

    static func runs(
        in result: AppliedSemanticBlockSplit,
        at index: Int
    ) throws -> [SemanticRun]
    {
        let block = result.document.content.blocks[index].block
        return try #require(EditableSemanticBlock(block)).runs
    }

    static func text(
        in result: AppliedSemanticBlockSplit,
        at index: Int
    ) throws -> String
    {
        try runs(in: result, at: index).map(\.text).joined()
    }

    static func scalarValues(_ text: String) -> [UInt32]
    {
        text.unicodeScalars.map(\.value)
    }
}
