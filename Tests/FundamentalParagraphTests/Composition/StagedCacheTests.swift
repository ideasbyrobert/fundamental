@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
struct StagedCacheTests
{
    @Test func bothPassesKeepStableTiesAndReuseMeasurements() throws
    {
        let cases = try [StagedFixture.tie()] + ComposerWitness.paragraphs()
        var records: [[String: Any]] = []
        for (index, original) in cases.enumerated()
        {
            let cache = try ParagraphFixture.cache(original.collection)
            let search = StagedParagraphOptimizer(
                cache: cache, width: original.width
            )
            let result = try search.optimize()
            let measurements = cache.nativeMeasurements
            for _ in 0..<4
            {
                let replay = try search.optimize()
                #expect(replay.path.nodes == result.path.nodes)
                #expect(replay.path.score == result.path.score)
                #expect(replay.usedFallback == result.usedFallback)
                #expect(cache.nativeMeasurements == measurements)
                #expect(replay.ordinaryMeasurements == 0)
            }
            if index == 0
            {
                #expect(result.path.nodes == [2, 5, 7, 8])
                #expect(result.usedFallback)
            }
            else
            {
                #expect(!result.usedFallback)
            }
            records.append([
                "path": result.path.nodes, "fallback": result.usedFallback,
                "measurements": measurements, "replays": 4
            ])
        }
        try PatternEvidence.write("cache", group: "staged-controls", record: [
            "comparisons": records
        ])
    }
}
