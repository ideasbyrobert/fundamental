@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
extension ParagraphEvidence
{
    static func describe(_ line: ParagraphPlannedLine) -> [String: Any]
    {
        [
            "source": [
                line.sourceRange.lowerBound, line.sourceRange.upperBound
            ],
            "tail": line.tail.map(ExplicitEvidence.describe),
            "ending": point(line.ending),
            "shaped": AutomaticEvidence.describe(line.shaped),
            "metrics": [
                "naturalAdvance": line.metrics.advance,
                "trailingWhitespace": line.metrics.trailingWhitespace,
                "gaps": line.metrics.gaps.map
                {
                    ["index": $0.index, "advance": $0.advance] as [String: Any]
                }
            ],
            "spacing": [
                "kind": line.spacing.kind.rawValue,
                "adjustment": line.spacing.adjustment,
                "advance": line.spacing.advance,
                "ratio": line.spacing.ratio,
                "fitness": line.spacing.fitness.rawValue
            ]
        ]
    }
}
