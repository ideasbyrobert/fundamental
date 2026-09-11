@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
struct TerminalPenaltyTests
{
    @Test func automaticAndAuthoredHyphensAddTheDeclaredTerminalCost() throws
    {
        let collection = try AutomaticFixture.text(
            "re\u{AD}presentation extraordinary co-operate"
        )
        let points = try ParagraphFixture.cache(collection).candidates.breaks
        let terminal = try #require(points.last)
        let kinds = [2, 3]
        var observations: [[String: Any]] = []
        for kind in kinds
        {
            for previous in points.filter({ $0.kind.rank == kind })
            {
                for advance in [15.0, 25]
                {
                    let spacing = ParagraphSpacing(
                        kind: .natural, adjustment: 0, advance: advance,
                        ratio: 0, fitness: .normal
                    )
                    let penalty = try TerminalCost.penalty(
                        spacing, width: 100, end: terminal, previous: previous
                    )
                    #expect(penalty == (advance == 15 ? 17000 : 5000))
                    observations.append([
                        "break": ParagraphEvidence.point(previous),
                        "advance": advance, "extra": penalty
                    ])
                }
            }
        }
        #expect(observations.count >= 6)
        try PatternEvidence.write(
            "hyphens", group: "terminal-controls",
            record: ["observations": observations]
        )
    }
}
