@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import Testing

@MainActor
@Suite
struct AutomaticMixedDisplayTests
{
    @Test
    func automaticBreakRetainsEarlierSuppressedMarker() throws
    {
        let value = try AutomaticFixture.text(
            "re\u{AD}presentation extraordinary"
        )
        #expect(value.inks.map(\.candidate.sourceOffset) == [18, 21, 23, 25])
        let selected = try AutomaticFixture.line(
            value, range: 0..<21, end: .automatic(value.selectAutomatic(1))
        )
        let authored = try AutomaticFixture.line(
            value, range: 0..<3, end: .explicit(value.explicit.select(0))
        )
        try AutomaticAssertions.compare(
            selected, text: "representation extra‐",
            reference: ShapingReference.line([("representation extra‐", [])])
        )
        try AutomaticAssertions.compare(
            authored, text: "re‐",
            reference: ShapingReference.line([("re‐", [])])
        )
        #expect(selected.display.body.units.count == 20)
        let generated = try selected.display.sources(in: 20..<21)
        #expect(generated == [.generated(value.inks[1])])
        #expect(value.inks[1].sourceRange == 21..<21)
        let remainder = try value.explicit.project(21..<29)
        #expect(try ExplicitFixture.reconstructed(selected.display.body.slice)
            + ExplicitFixture.reconstructed(remainder)
            == Array("re\u{AD}presentation extraordinary".utf16))
        for lower in selected.display.units.indices
        {
            for upper in (lower + 1)...selected.display.units.count
            {
                let range = lower..<upper
                try AutomaticAssertions.sources(
                    selected.display, range: range,
                    values: selected.display.sources(in: range)
                )
            }
        }
        for range in [-1..<1, 0..<0, 0..<Int.max, 21..<22]
        {
            #expect(throws: ExplicitShapingFailure.displayRange(range))
            {
                try selected.display.sources(in: range)
            }
        }
        try AutomaticEvidence.write(
            "mixed-displays", collection: value, lines: [authored, selected],
            extra: ["sourceQueries": 231, "invalidQueries": 4]
        )
    }

    @Test
    func emptyAndShortParagraphsHaveNoGeneratedInk() throws
    {
        for (index, text) in ["", "a", "\u{AD}"].enumerated()
        {
            let value = try AutomaticFixture.text(text)
            #expect(value.inks.isEmpty)
            let line = try AutomaticFixture.line(
                value, range: 0..<text.utf16.count
            )
            let expected = index == 1 ? "a" : ""
            try AutomaticAssertions.compare(
                line, text: expected,
                reference: ShapingReference.line([(expected, [])])
            )
            try AutomaticEvidence.write(
                "empty-short-" + String(index), collection: value, lines: [line]
            )
        }
    }
}
