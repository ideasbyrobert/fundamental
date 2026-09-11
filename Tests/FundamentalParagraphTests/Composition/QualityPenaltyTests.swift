@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
struct QualityPenaltyTests
{
    @Test func penaltiesAndFitnessHistory() throws
    {
        let collection = try AutomaticFixture.text(
            "re\u{AD}presentation extraordinary"
        )
        let points = try ParagraphFixture.cache(collection).candidates.breaks
        let authored = try #require(points.first { $0.kind.rank == 2 })
        let automatic = try #require(points.first { $0.kind.rank == 3 })
        let space = try #require(points.first { $0.kind.rank == 1 })
        let terminal = try #require(points.last)
        let natural = ParagraphSpacing(
            kind: .natural, adjustment: 0, advance: 10,
            ratio: 0, fitness: .normal
        )
        let loose = ParagraphSpacing(
            kind: .justified, adjustment: 1, advance: 10,
            ratio: 1, fitness: .veryLoose
        )
        func cost(
            _ line: ParagraphSpacing, _ end: ParagraphBreak,
            _ previous: ParagraphBreak, _ fitness: ParagraphFitness
        ) throws -> Double
        {
            try QualityScore.zero.appending(
                line, end: end, previous: previous, fitness: fitness
            ).demerits
        }
        #expect(try cost(natural, authored, points[0], .normal) == 200)
        #expect(try cost(natural, automatic, points[0], .normal) == 2600)
        #expect(try cost(natural, automatic, authored, .normal) == 5600)
        #expect(try cost(loose, space, space, .tight) == 15100)
        #expect(try cost(loose, space, points[0], .tight) == 12100)
        #expect(try cost(natural, terminal, space, .tight) == 100)
        let visible = try ParagraphFixture.cache(
            AutomaticFixture.text("co-operate")
        ).candidates.breaks
        let dash = try #require(visible.first { $0.kind.rank == 2 })
        #expect(try cost(natural, dash, visible[0], .normal) == 100)
        try PatternEvidence.write("penalties", group: "quality-controls",
                                  record: ["costs": [
                                      200, 2600, 5600, 15100, 12100, 100, 100
                                  ]])
    }

}
