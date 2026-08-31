import Testing

@testable import FundamentalDocument

@Suite("A semantic code block")
struct SemanticCodeBlockTests
{
    @Test("both forms expose only their exact occupied runs")
    func formsExposeExactOccupiedRuns() throws
    {
        let plainRuns = [SemanticRun(text: "Plain")]
        let taggedRuns = [SemanticRun(text: "Tagged")]
        let language = try #require(
            SemanticCodeLanguageIdentifier("swift")
        )
        let plain = SemanticCodeBlock.plain(
            PlainSemanticCodeBlock(runs: plainRuns)
        )
        let tagged = SemanticCodeBlock.languageTagged(
            LanguageTaggedSemanticCodeBlock(
                runs: taggedRuns,
                language: language
            )
        )

        #expect(plain.runs == plainRuns)
        #expect(tagged.runs == taggedRuns)
    }

    @Test("plain and language tagged empty forms remain distinct")
    func emptyFormsRemainDistinct() throws
    {
        let language = try #require(
            SemanticCodeLanguageIdentifier("text")
        )
        let plain = SemanticCodeBlock.plain(
            PlainSemanticCodeBlock(runs: [])
        )
        let tagged = SemanticCodeBlock.languageTagged(
            LanguageTaggedSemanticCodeBlock(
                runs: [],
                language: language
            )
        )

        #expect(plain != tagged)
        #expect(plain.runs.isEmpty)
        #expect(tagged.runs.isEmpty)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let language = try #require(
            SemanticCodeLanguageIdentifier("swift")
        )
        let run = SemanticRun(text: "Code")
        let original = SemanticCodeBlock.plain(
            PlainSemanticCodeBlock(runs: [run])
        )
        let replacement = SemanticCodeBlock.languageTagged(
            LanguageTaggedSemanticCodeBlock(
                runs: [run],
                language: language
            )
        )

        #expect(original == .plain(
            PlainSemanticCodeBlock(runs: [run])
        ))
        #expect(replacement != original)
    }
}
