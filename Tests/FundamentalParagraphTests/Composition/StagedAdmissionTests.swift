@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
struct StagedAdmissionTests
{
    @Test func invalidWidthsAndUnfittableCharactersRemainErrors() throws
    {
        let original = try ParagraphFixture.compose(
            AutomaticFixture.text("aa bb"), width: 100
        )
        let cache = try ParagraphFixture.cache(original.collection)
        for width in [0, -1, Double.nan, .infinity, -.infinity]
        {
            #expect(throws: ParagraphFailure.invalidWidth)
            {
                try StagedParagraphOptimizer(
                    cache: cache, width: width
                ).optimize()
            }
            #expect(throws: ParagraphFailure.invalidWidth)
            {
                try StagedParagraphComposition(original, width: width)
            }
        }
        #expect(cache.nativeMeasurements == 0 && cache.requests == 0)
        let emoji = try AutomaticFixture.text("👩‍💻")
        let fullCache = try ParagraphFixture.cache(emoji)
        let stagedCache = try ParagraphFixture.cache(emoji)
        #expect(throws: ParagraphFailure.noFeasibleLayout(0..<5))
        {
            try TerminalOptimizer(cache: fullCache, width: 1).optimize()
        }
        #expect(throws: ParagraphFailure.noFeasibleLayout(0..<5))
        {
            try StagedParagraphOptimizer(
                cache: stagedCache, width: 1
            ).optimize()
        }
        #expect(
            stagedCache.nativeMeasurements == fullCache.nativeMeasurements
        )
        try PatternEvidence.write(
            "admission", group: "staged-controls", record: [
            "invalidWidthRefusals": 10, "unfittableRefusals": 2,
            "fullMeasurements": fullCache.nativeMeasurements,
            "stagedMeasurements": stagedCache.nativeMeasurements
            ]
        )
    }
}
