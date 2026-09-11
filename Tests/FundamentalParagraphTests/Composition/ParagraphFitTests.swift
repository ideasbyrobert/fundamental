@testable import FundamentalNativeParagraph
import Testing

struct ParagraphFitTests
{
    @Test func spacingLimitsAndTerminalBehavior() throws
    {
        let metrics = ParagraphLineMetrics(advance: 100, gapWidths: [10, 20])
        let cases: [(Double, Bool, ParagraphSpacing.Kind, Double)] = [
            (100, false, .natural, 0), (120, true, .natural, 0),
            (115, false, .justified, 7.5), (95, false, .justified, -2.5),
            (115.001, false, .ragged, 0), (95, true, .justified, -2.5)
        ]
        for (width, terminal, kind, adjustment) in cases
        {
            let fit = ParagraphLineFit(
                metrics: metrics, width: width, terminal: terminal
            )
            guard case let .admitted(spacing) = fit
            else
            {
                Issue.record("Expected admitted spacing")
                continue
            }
            #expect(spacing.kind == kind)
            #expect(spacing.adjustment == adjustment)
            #expect(spacing.advance <= width)
        }
        guard case .unavailable = ParagraphLineFit(
            metrics: metrics, width: 94.999, terminal: false
        )
        else
        {
            Issue.record("An overlong line exceeded its shrink allowance")
            return
        }
        try PatternEvidence.write("limits", group: "paragraph-controls",
                                  record: ["cases": cases.count, "refusals": 1])
    }

    @Test func fixedGapsCannotJustifyAndFitnessThresholdsAreExplicit()
    {
        let metrics = ParagraphLineMetrics(advance: 100, gapWidths: [])
        if case let .admitted(spacing) = ParagraphLineFit(
            metrics: metrics, width: 105, terminal: false
        )
        {
            #expect(spacing.kind == .ragged)
        }
        else
        {
            Issue.record("A naturally fitting fixed line must remain feasible")
        }
        let cases: [(Double, ParagraphFitness)] = [
            (-1, .tight), (-0.5001, .tight), (-0.5, .normal),
            (0, .normal), (0.5, .normal), (0.5001, .loose),
            (0.8, .loose), (0.8001, .veryLoose), (1, .veryLoose)
        ]
        for (ratio, fitness) in cases
        {
            #expect(ParagraphFitness(ratio: ratio) == fitness)
        }
    }
}
