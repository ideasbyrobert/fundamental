@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import AppKit
import Testing

@MainActor
struct ParagraphCacheTests
{
    @Test func equivalentOriginsAndFitnessStatesReuseNativeMeasurements() throws
    {
        let value = try AutomaticFixture.text(
            "wide in wide the in the word wide in the a"
        )
        let cache = try ParagraphFixture.cache(value)
        let points = cache.candidates.breaks
        let space = try #require(points.indices.first
        {
            points[$0].kind.rank == 1
        })
        let emergency = try #require(points.indices.first
        {
            points[$0].position == points[space].position
                && points[$0].kind.rank == 4
        })
        let last = points.count - 1
        _ = try cache.measure(from: space, to: last)
        let first = cache.nativeMeasurements
        _ = try cache.measure(from: emergency, to: last)
        #expect(cache.nativeMeasurements == first)
        let path = try LegacyParagraphOptimizer(
            cache: cache, width: 52.5
        ).optimize()
        let measured = cache.nativeMeasurements
        let repeated = try LegacyParagraphOptimizer(
            cache: cache, width: 52.5
        ).optimize()
        #expect(path.nodes == repeated.nodes)
        #expect(cache.nativeMeasurements == measured)
        #expect(cache.requests > measured)
        let plan = try ParagraphSegmentPlan(
            cache: cache, path: path, width: 52.5
        )
        #expect(plan.nativeMeasurements == measured + plan.lines.count)
        #expect(cache.nativeMeasurements == measured)
        try PatternEvidence.write("cache", group: "paragraph-controls", record:
        [
            "nativeMeasurements": measured, "requests": cache.requests,
            "transitions": path.transitions, "states": path.statesRetained,
            "winningReshapes": plan.lines.count,
            "equivalentOriginRequests": 2, "equivalentOriginMeasurements": first
        ])
    }

    @Test func identicalSemanticRunsResolveOncePerOriginalIndex() throws
    {
        let source = try WordFixture.source([
            WordFixture.run("aa"), WordFixture.run("aa"), WordFixture.run("")
        ])
        var calls = 0
        let result = try ParagraphComposition(legacy:
            AutomaticFixture.collection(source), width: 200
        )
        {
            run in
            calls += 1
            return try ShapingFixture.attributes(run, size: Double(calls * 10))
        }
        #expect(calls == 3)
        try ParagraphAssertions.verify(result)
        let line = try #require(result.segments.first?.lines.first)
        #expect(line.shaped.runs.map(\.font.pointSize) == [10, 20])
        let sizes = result.attributes.values.map
        {
            ($0[.font] as! NSFont).pointSize
        }
        #expect(sizes == [10, 20, 30])
        try ParagraphEvidence.write("indexed-fonts", result: result)
    }
}
