@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
struct ParagraphTieTests
{
    @Test func equalScoringPathsRetainTheEarlierPredecessor() throws
    {
        let value = try AutomaticFixture.collection(
            ExplicitFixture.source("WW\u{AD}WWWWW", language: "zz_ZZ")
        )
        let cache = try ParagraphFixture.cache(value)
        let width = 40.0
        let reference = try ExhaustiveParagraphSearch(
            cache: cache, width: width
        ).run()
        let result = try LegacyParagraphOptimizer(
            cache: cache, width: width
        ).optimize()
        ParagraphAssertions.scoresEqual(result.score, reference.best.score)
        for _ in 0..<4
        {
            let replay = try LegacyParagraphOptimizer(
                cache: cache, width: width
            ).optimize()
            #expect(replay.nodes == result.nodes)
        }
        #expect(result.nodes == [2, 5, 7, 8])
        let alternative = [3, 5, 7, 8]
        var score = ParagraphScore.zero
        var previous = 0
        var fitness = 1
        for next in alternative
        {
            guard case let .measured(metrics) = try cache.measure(
                      from: previous, to: next
                  ),
                  let line = ReferenceLineAssessment.assess(
                      metrics, width: width,
                      terminal: cache.candidates.breaks[next].terminal
                  )
            else
            {
                Issue.record("Expected the alternative tied path to fit")
                return
            }
            score = line.extending(
                score, previousFitness: fitness,
                previous: cache.candidates.breaks[previous],
                next: cache.candidates.breaks[next]
            )
            fitness = line.fitness
            previous = next
        }
        ParagraphAssertions.scoresEqual(result.score, score)
        try PatternEvidence.write("ties", group: "paragraph-controls", record: [
            "width": width, "path": result.nodes,
            "score": ParagraphEvidence.score(result.score),
            "completePaths": reference.completePaths,
            "alternative": alternative,
            "alternativeScore": ParagraphEvidence.score(score)
        ])
    }
}
