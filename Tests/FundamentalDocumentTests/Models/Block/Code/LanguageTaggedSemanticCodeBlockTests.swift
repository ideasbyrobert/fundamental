import Testing

@testable import FundamentalDocument

@Suite("A language tagged semantic code block")
struct LanguageTaggedSemanticCodeBlockTests
{
    @Test("initialization preserves its required immutable facts")
    func initializationPreservesRequiredFacts() throws
    {
        let language = try #require(
            SemanticCodeLanguageIdentifier(" swift ")
        )
        let runs = [SemanticRun(text: "let value = 1")]
        let block = LanguageTaggedSemanticCodeBlock(
            runs: runs,
            language: language
        )

        #expect(block.runs == runs)
        #expect(block.language == language)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let swift = try #require(
            SemanticCodeLanguageIdentifier("swift")
        )
        let rust = try #require(
            SemanticCodeLanguageIdentifier("rust")
        )
        let run = SemanticRun(text: "Code")
        let original = LanguageTaggedSemanticCodeBlock(
            runs: [run],
            language: swift
        )
        let replacement = LanguageTaggedSemanticCodeBlock(
            runs: [run],
            language: rust
        )

        #expect(original.language == swift)
        #expect(replacement.language == rust)
    }
}
