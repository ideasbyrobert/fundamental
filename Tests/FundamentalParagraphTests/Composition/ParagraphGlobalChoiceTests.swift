@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
struct ParagraphGlobalChoiceTests
{
    @Test func localChoiceAndCollapsedFitnessLoseBetterCompletePaths() throws
    {
        let cases = [
            ("greedy", "of of line of line wide to", 47.5),
            ("fitness", "wide in wide the in the word wide in the a", 52.5)
        ]
        for (name, text, width) in cases
        {
            let value = try AutomaticFixture.text(text)
            let cache = try ParagraphFixture.cache(value)
            let path = try LegacyParagraphOptimizer(
                cache: cache, width: width
            ).optimize()
            let greedy = try GreedyParagraphSearch(
                cache: cache, width: width
            ).run()
            let collapsed = try CollapsedParagraphSearch(
                cache: cache, width: width
            ).run()
            let reference = try ExhaustiveParagraphSearch(
                cache: cache, width: width
            ).run(upperBound: greedy.score)
            ParagraphAssertions.scoresEqual(path.score, reference.best.score)
            if name == "greedy"
            {
                #expect(path.score.emergency == 0)
                #expect(greedy.score.emergency == 0)
                #expect(path.score.ragged == 2 && greedy.score.ragged == 3)
                #expect(path.score < greedy.score)
            }
            else
            {
                #expect(path.score.emergency == 0)
                #expect(path.score.ragged == 4 && collapsed.score.ragged == 4)
                #expect(abs(collapsed.score.demerits - path.score.demerits
                    - 3000) < 0.000001)
                #expect(path.score < collapsed.score)
                #expect(path.statesRetained > cache.candidates.breaks.count)
            }
            let result = try ParagraphFixture.compose(value, width: width)
            try ParagraphAssertions.verify(result)
            try ParagraphEvidence.write(name, result: result)
            try PatternEvidence.write(
                name, group: "paragraph-controls", record: [
                    "optimal": ParagraphEvidence.score(path.score),
                    "greedy": ParagraphEvidence.score(greedy.score),
                    "collapsed": ParagraphEvidence.score(collapsed.score),
                    "optimalPath": path.nodes, "greedyPath": greedy.nodes,
                    "collapsedPath": collapsed.nodes,
                    "referencePath": reference.best.nodes,
                    "completePaths": reference.completePaths,
                    "prunedPrefixes": reference.pruned
                ]
            )
        }
    }
}
