@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
struct StagedOracleTests
{
    @Test func smallNativeGraphsAgreeWithEveryCompleteReferencePath() throws
    {
        let texts = ["aa bb cc", "a a a a", "a-b c", "a\u{AD}b c",
                     "a\u{301} b 👩‍💻", "район"]
        var records: [[String: Any]] = []
        for (index, text) in texts.enumerated()
        {
            let collection = try AutomaticFixture.collection(
                ExplicitFixture.source(
                    text, language: index == 5 ? "ru_RU" : "en_US"
                ),
                language: index == 5 ? .russian : .english
            )
            for width in [30.0, 45, 70]
            {
                let cache = try ParagraphFixture.cache(collection)
                let result = try StagedParagraphOptimizer(
                    cache: cache, width: width
                ).optimize()
                let full = try TerminalOptimizer(
                    cache: cache, width: width
                ).optimize()
                let reference = try TerminalReferenceSearch(
                    cache: cache, width: width
                ).run()
                #expect(result.path.nodes == full.nodes)
                #expect(result.path.score == full.score)
                ComposerEvidence.equal(
                    result.path.score, reference.best.score
                )
                records.append([
                    "text": text, "width": width,
                    "path": result.path.nodes,
                    "reference": reference.best.nodes,
                    "score": ComposerEvidence.score(result.path.score),
                    "fallback": result.usedFallback,
                    "completePaths": reference.completePaths
                ])
            }
        }
        try PatternEvidence.write("oracle", group: "staged-controls", record: [
            "comparisons": records
        ])
    }
}
