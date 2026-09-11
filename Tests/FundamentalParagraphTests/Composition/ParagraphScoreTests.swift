@testable import FundamentalNativeParagraph
import Testing

@MainActor
struct ParagraphScoreTests
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
            try ParagraphScore.zero.appending(
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
        try PatternEvidence.write("penalties", group: "paragraph-controls",
                                  record: ["costs": [
                                      200, 2600, 5600, 15100, 12100, 100, 100
                                  ]])
    }

    @Test func lexicographicScoreAndOverflow() throws
    {
        let emergency = ParagraphBreak(
            position: 1, visibleEnd: 1, kind: .emergency
        )
        let start = ParagraphBreak(position: 0, visibleEnd: 0, kind: .start)
        let ragged = ParagraphSpacing(
            kind: .ragged, adjustment: 0, advance: 1,
            ratio: 0.5, fitness: .ragged
        )
        let scores = [
            ParagraphScore(emergency: 0, ragged: 2, demerits: 90000),
            ParagraphScore(emergency: 1, ragged: 0, demerits: 0),
            ParagraphScore(emergency: 1, ragged: 1, demerits: 0)
        ]
        #expect(scores[0] < scores[1] && scores[1] < scores[2])
        for score in [
            ParagraphScore(emergency: .max, ragged: 0, demerits: 0),
            ParagraphScore(emergency: 0, ragged: .max, demerits: 0),
            ParagraphScore(emergency: 0, ragged: 0, demerits: .infinity)
        ]
        {
            #expect(throws: ParagraphFailure.scoreOverflow)
            {
                try score.appending(
                    ragged, end: emergency, previous: start, fitness: .normal
                )
            }
        }
    }
}
