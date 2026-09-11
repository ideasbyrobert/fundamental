@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import Testing

@MainActor
@Suite
struct ShapedLiteralTests
{
    @Test(arguments: [18.0, 36.0])
    func everyAcceptedLiteralDisplay(_ size: Double) throws
    {
        for fixture in ExplicitCases.all
        {
            let source = try ExplicitFixture.source(
                fixture.text, language: fixture.language
            )
            let value = ExplicitParagraphHyphens(source)
            let end = source.source.utf16.count
            var lines = [try ShapingFixture.line(
                value, range: 0..<end, size: size
            )]
            var expected = [fixture.unbroken]
            for (index, entry) in zip(
                ExplicitFixture.indices(value), fixture.breaks
            )
            {
                lines.append(try ShapingFixture.line(
                    value, range: 0..<entry.offset,
                    end: .opportunity(value.select(index)), size: size
                ))
                lines.append(try ShapingFixture.line(
                    value, range: entry.offset..<end, size: size
                ))
                expected += [entry.prefix, entry.suffix]
            }
            #expect(lines.count == 1 + fixture.breaks.count * 2)
            for (line, text) in zip(lines, expected)
            {
                try ShapingAssertions.compare(
                    line, text: text,
                    reference: ShapingReference.line([(text, [])], size: size)
                )
            }
            try ShapingEvidence.write(
                fixture.name + "-" + String(Int(size)),
                lines: lines, extra: ["literalDisplays": expected]
            )
        }
    }

    @Test
    func emptyAndAllSuppressedDisplayRetainTheirSource() throws
    {
        for (index, text) in ["", "\u{AD}", "\u{AD}\u{AD}"].enumerated()
        {
            let value = try ShapingFixture.collection(text)
            let line = try ShapingFixture.line(
                value, range: 0..<text.utf16.count
            )
            #expect(line.measurement.native == nil)
            #expect(line.measurement.advance == 0)
            #expect(line.measurement.trailingWhitespace == 0)
            #expect(line.runs.isEmpty)
            #expect(line.display.units.isEmpty)
            #expect(try ExplicitFixture.reconstructed(line.display.slice)
                == Array(text.utf16))
            try ShapingEvidence.write(
                "suppressed-" + String(index), lines: [line]
            )
        }
    }
}
