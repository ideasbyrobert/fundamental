import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockMergeTests
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
        language: String
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

    static func scalarValues(_ text: String) -> [UInt32]
    {
        text.unicodeScalars.map(\.value)
    }

    static func contrastingRuns(
        leadingText: String = "A",
        trailingText: String = "B"
    ) throws -> ([SemanticRun], [SemanticRun])
    {
        let scopeValues = try SemanticRunAttributesTests.scopes()
        let scopes = try #require(scopeValues.last)
        return (
            [SemanticRun(text: leadingText, traits: [.strong])],
            [SemanticRun(
                text: trailingText,
                attributes: .scoped(
                    traits: [.emphasis],
                    scopes: scopes
                )
            )]
        )
    }
}
