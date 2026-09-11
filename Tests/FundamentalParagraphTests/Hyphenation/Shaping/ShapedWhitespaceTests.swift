@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import AppKit
import CoreText
import Testing

@MainActor
@Suite
struct ShapedWhitespaceTests
{
    @Test
    func trailingWhitespaceIsMeasuredSeparately() throws
    {
        let value = try ShapingFixture.collection("extra\u{AD}ordinary  ")
        let line = try ShapingFixture.line(value, range: 0..<16)
        let plain = try ShapingReference.line([("extraordinary", [])])
        try ShapingAssertions.compare(
            line, text: "extraordinary  ",
            reference: ShapingReference.line([("extraordinary  ", [])])
        )
        #expect(line.measurement.trailingWhitespace > 0)
        #expect(abs(line.measurement.advance
            - line.measurement.trailingWhitespace
            - CTLineGetTypographicBounds(plain, nil, nil, nil)) < 0.000001)
        try ShapingEvidence.write("trailing-spaces", lines: [line])
    }

    @Test
    func tabsRetainTheirInlineOffsetContext() throws
    {
        let value = try ShapingFixture.collection("a\u{AD}b a\t")
        let style = NSMutableParagraphStyle()
        style.tabStops = [
            NSTextTab(textAlignment: .left, location: 120),
            NSTextTab(textAlignment: .left, location: 240)
        ]
        style.defaultTabInterval = 120
        let immutable = style.copy() as! NSParagraphStyle
        var lines: [ExplicitShapedLine] = []
        for offset in [0.0, 37.0]
        {
            let line = try ExplicitShapedLine(
                value, range: 0..<6, inlineOffset: offset
            )
            {
                var attributes = try ShapingFixture.attributes($0, size: 18)
                attributes[.paragraphStyle] = immutable
                return attributes
            }
            try ShapingAssertions.compare(
                line, text: "ab a\t",
                reference: ShapingReference.line(
                    [("ab a\t", [])], offset: offset,
                    extra: [.paragraphStyle: immutable]
                )
            )
            lines.append(line)
        }
        #expect(abs(lines[0].measurement.advance
            - lines[1].measurement.advance) > 0.5)
        try ShapingEvidence.write("contextual-tabs", lines: lines)
    }
}
