@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
struct ParagraphOracleTests
{
    @Test func exhaustivePathsAgreeWithWholeParagraphOptimization() throws
    {
        let texts = ["aa bb cc", "a a a a", "a-b c", "a\u{AD}b c",
                     "a\u{301} b 👩‍💻", "район"]
        var records: [[String: Any]] = []
        for (index, text) in texts.enumerated()
        {
            let language = index == 5 ? "ru_RU" : "en_US"
            let value = try AutomaticFixture.collection(
                ExplicitFixture.source(text, language: language),
                language: index == 5 ? .russian : .english
            )
            let cache = try ParagraphFixture.cache(value)
            for width in [30.0, 45, 70]
            {
                let path = try LegacyParagraphOptimizer(
                    cache: cache, width: width
                ).optimize()
                let reference = try ExhaustiveParagraphSearch(
                    cache: cache, width: width
                ).run()
                ParagraphAssertions.scoresEqual(
                    path.score, reference.best.score
                )
                #expect(reference.completePaths > 0)
                records.append([
                    "text": text, "width": width,
                    "score": ParagraphEvidence.score(path.score),
                    "path": path.nodes, "reference": reference.best.nodes,
                    "completePaths": reference.completePaths
                ])
            }
        }
        try PatternEvidence.write("exhaustive", group: "paragraph-controls",
                                  record: ["comparisons": records])
    }
}
