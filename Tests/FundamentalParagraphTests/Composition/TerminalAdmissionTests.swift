@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
struct TerminalAdmissionTests
{
    @Test func invalidInputAndUnfittableCharactersAreRefused() throws
    {
        let original = try ParagraphFixture.compose(
            AutomaticFixture.text("aa bb"), width: 100
        )
        let cache = try ParagraphFixture.cache(original.collection)
        for width in [0, -1, Double.nan, .infinity, -.infinity]
        {
            #expect(throws: ParagraphFailure.invalidWidth)
            {
                try TerminalOptimizer(cache: cache, width: width).optimize()
            }
            #expect(throws: ParagraphFailure.invalidWidth)
            {
                try TerminalComposition(original, width: width)
            }
        }
        #expect(cache.nativeMeasurements == 0)
        let emoji = try ParagraphFixture.compose(
            AutomaticFixture.text("👩‍💻"), width: 100
        )
        #expect(throws: ParagraphFailure.noFeasibleLayout(0..<5))
        {
            try TerminalComposition(emoji, width: 1)
        }
        try PatternEvidence.write(
            "admission", group: "terminal-controls",
            record: ["widthRefusals": 10, "unfittableRefusals": 1]
        )
    }

    @Test func nonfiniteAdvanceAndCumulativeScoreAreRefused() throws
    {
        let end = ParagraphBreak(
            position: 2, visibleEnd: 2, kind: .terminal(.end)
        )
        let previous = ParagraphBreak(
            position: 1, visibleEnd: 1, kind: .space
        )
        for advance in [-1, Double.nan, .infinity]
        {
            #expect(throws: TerminalFailure.invalidAdvance)
            {
                try TerminalCost.penalty(
                    .init(kind: .natural, adjustment: 0, advance: advance,
                          ratio: 0, fitness: .normal),
                    width: 100, end: end, previous: previous
                )
            }
        }
        for cost in [Double.infinity, .nan]
        {
            #expect(throws: ParagraphFailure.scoreOverflow)
            {
                try TerminalCost.adding(
                    to: .init(emergency: 0, demerits: cost),
                    spacing: .init(kind: .natural, adjustment: 0, advance: 15,
                                   ratio: 0, fitness: .normal),
                    width: 100, end: end, previous: previous
                )
            }
        }
    }
}
