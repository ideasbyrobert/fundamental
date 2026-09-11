@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

struct QualityOverflowTests
{
    @Test func nonfiniteAndOverflowingCostsAreExplicitRefusals() throws
    {
        let end = ParagraphBreak(
            position: 1, visibleEnd: 1, kind: .emergency
        )
        let start = ParagraphBreak(position: 0, visibleEnd: 0, kind: .start)
        let normal = ParagraphSpacing(
            kind: .ragged, adjustment: 0, advance: 1,
            ratio: 0.5, fitness: .ragged
        )
        for score in [
            QualityScore(emergency: .max, demerits: 0),
            QualityScore(emergency: 0, demerits: .infinity),
            QualityScore(emergency: 0, demerits: .nan)
        ]
        {
            #expect(throws: ParagraphFailure.scoreOverflow)
            {
                try score.appending(
                    normal, end: end, previous: start, fitness: .normal
                )
            }
        }
        for ratio in [Double.infinity, .nan, .greatestFiniteMagnitude]
        {
            let spacing = ParagraphSpacing(
                kind: .ragged, adjustment: 0, advance: 1,
                ratio: ratio, fitness: .ragged
            )
            #expect(throws: ParagraphFailure.scoreOverflow)
            {
                try QualityScore.zero.appending(
                    spacing, end: end, previous: start, fitness: .normal
                )
            }
        }
        try PatternEvidence.write(
            "overflow", group: "quality-controls",
            record: ["invalidScores": 3, "invalidRatios": 3]
        )
    }
}
