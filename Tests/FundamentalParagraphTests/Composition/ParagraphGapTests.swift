@testable import FundamentalNativeParagraph
import Testing

@MainActor
struct ParagraphGapTests
{
    @Test func onlyInternalSpaceGlyphsAreAdjustable() throws
    {
        let value = try AutomaticFixture.text(" a  b\tc ")
        let attributes = try ParagraphAttributes(value.source)
        {
            try ShapingFixture.attributes($0, size: 18)
        }
        let display = try HyphenatedDisplay(
            value, range: 0..<8, end: .unbroken
        )
        let line = try ParagraphMeasurement.measure(
            display, attributes: attributes
        )
        let metrics = try ParagraphLineMetrics(line, units: display.units)
        #expect(metrics.gaps.map(\.index) == [2, 3])
        #expect(metrics.gaps.allSatisfy
        {
            $0.advance > 0
        })
        #expect(metrics.trailingWhitespace > 0)
        #expect(metrics.advance == line.advance)
        try PatternEvidence.write("gaps", group: "paragraph-controls", record:
        [
            "displayUTF16": display.units, "advance": metrics.advance,
            "trailingWhitespace": metrics.trailingWhitespace,
            "gapIndices": metrics.gaps.map(\.index),
            "gapAdvances": metrics.gaps.map(\.advance)
        ])
    }
}
