@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import Testing

@MainActor
@Suite
struct ShapedRangeTests
{
    @Test
    func nonzeroSourceSlicesKeepAbsoluteAndRunLocalCoordinates() throws
    {
        let value = try ShapingFixture.collection("pre extra\u{AD}ordinary end")
        let first = try ShapingFixture.line(
            value, range: 4..<10, end: .opportunity(value.select(0))
        )
        let second = try ShapingFixture.line(value, range: 10..<18)
        try ShapingAssertions.compare(
            first, text: "extra‐",
            reference: ShapingReference.line([("extra‐", [])])
        )
        try ShapingAssertions.compare(
            second, text: "ordinary",
            reference: ShapingReference.line([("ordinary", [])])
        )
        #expect(second.runs.flatMap(\.glyphs).flatMap(\.sources)
            .allSatisfy { $0.fragment.paragraphRange.lowerBound >= 10 })
        try ShapingEvidence.write("partial-source", lines: [first, second])
    }

    @Test
    func displayQueriesMatchIndependentPerUnitSourceOracle() throws
    {
        let value = ExplicitParagraphHyphens(try WordFixture.source([
            WordFixture.run("f\u{AD}i "), WordFixture.run("раи"),
            WordFixture.run("\u{306}\u{AD}он")
        ], language: "ru_RU"))
        let display = try ExplicitDisplayMap(value, range: 0..<11)
        var queries = 0
        for lower in display.units.indices
        {
            for upper in (lower + 1)...display.units.count
            {
                let range = lower..<upper
                try ShapingAssertions.sources(
                    display, query: range, actual: display.sources(in: range)
                )
                queries += 1
            }
        }
        let invalid = [
            -1..<1, 0..<0, 0..<Int.max,
            display.units.count..<(display.units.count + 1)
        ]
        for range in invalid
        {
            #expect(throws: ExplicitShapingFailure.displayRange(range))
            {
                try display.sources(in: range)
            }
        }
        try PatternEvidence.write("display-ranges", group: "shaping-controls",
                                  record: ["queries": queries,
                                           "invalid": invalid.map {
                                               [$0.lowerBound, $0.upperBound]
                                           }])
    }
}
