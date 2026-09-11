@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

struct TerminalCostTests
{
    @Test func quarterWidthCostsAreContinuousAndScaleInvariant() throws
    {
        let end = ParagraphBreak(
            position: 2, visibleEnd: 2, kind: .terminal(.end)
        )
        let previous = ParagraphBreak(
            position: 1, visibleEnd: 1, kind: .space
        )
        let cases = [
            (0.0, 2472656.25), (5.0, 656000.0), (15.0, 12000.0),
            (20.0, 406.25), (25.0, 0.0), (25.001, 0.0), (100.0, 0.0)
        ]
        var costs: [Double] = []
        for (advance, expected) in cases
        {
            for scale in [0.5, 1, 2, 10]
            {
                let spacing = ParagraphSpacing(
                    kind: .natural, adjustment: 0, advance: advance * scale,
                    ratio: 0, fitness: .normal
                )
                let cost = try TerminalCost.penalty(
                    spacing, width: 100 * scale, end: end, previous: previous
                )
                #expect(abs(cost - expected) < 0.000001)
                costs.append(cost)
            }
        }
        let near = ParagraphSpacing(
            kind: .natural, adjustment: 0, advance: 24.99,
            ratio: 0, fitness: .normal
        )
        let delta = try TerminalCost.penalty(
            near, width: 100, end: end, previous: previous
        )
        #expect(delta > 0 && delta < 0.00001)
        try PatternEvidence.write(
            "costs", group: "terminal-controls",
            record: ["costs": costs, "nearQuarterCost": delta]
        )
    }

    @Test func terminalPreferenceNeverOutranksEmergencyPriority() throws
    {
        let short = ParagraphSpacing(
            kind: .natural, adjustment: 0, advance: 0,
            ratio: 0, fitness: .normal
        )
        let score = try TerminalCost.adding(
            to: .zero, spacing: short, width: 100,
            end: .init(position: 2, visibleEnd: 2, kind: .terminal(.end)),
            previous: .init(position: 1, visibleEnd: 1, kind: .space)
        )
        #expect(score.emergency == 0)
        #expect(score < QualityScore(emergency: 1, demerits: 0))
    }
}
