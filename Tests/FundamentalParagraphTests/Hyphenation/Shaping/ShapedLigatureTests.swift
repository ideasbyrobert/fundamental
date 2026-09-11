@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import AppKit
import CoreText
import Testing

@MainActor
@Suite
struct ShapedLigatureTests
{
    @Test(arguments: [18.0, 36.0])
    func independentlyShapedCharactersDoNotDetermineLineWidth(
        _ size: Double
    ) throws
    {
        let text = "AVATAR"
        let value = try ShapingFixture.collection(text)
        let whole = try ShapingFixture.line(
            value, range: 0..<text.utf16.count, size: size
        )
        let separate = try text.map
        {
            CTLineGetTypographicBounds(
                try ShapingReference.line([(String($0), [])], size: size),
                nil, nil, nil
            )
        }
        #expect(abs(separate.reduce(0, +) - whole.measurement.advance) > 0.1)
        try ShapingAssertions.compare(
            whole, text: text,
            reference: ShapingReference.line([(text, [])], size: size)
        )
        try ShapingEvidence.write(
            "nonadditive-" + String(Int(size)), lines: [whole],
            extra: ["isolatedCharacterAdvances": separate]
        )
    }

    @Test(arguments: [18.0, 36.0])
    func ligatureMapsAcrossHiddenMarkerAndOriginalRunSeams(
        _ size: Double
    ) throws
    {
        let value = ExplicitParagraphHyphens(try WordFixture.source([
            WordFixture.run("f"), WordFixture.run("\u{AD}"),
            WordFixture.run("i")
        ]))
        let control = try ShapingFixture.line(value, range: 0..<3, size: size)
        try ShapingAssertions.compare(
            control, text: "fi",
            reference: ShapingReference.line([("fi", [])], size: size)
        )
        #expect(control.runs.flatMap(\.glyphs).count == 2)
        let font = try #require(NSFont(name: "Times-Roman", size: size))
        #expect(font.fontName == "Times-Roman")
        let line = try ExplicitShapedLine(value, range: 0..<3)
        {
            _ in
            [.font: font, .ligature: 1]
        }
        try ShapingAssertions.compare(
            line, text: "fi",
            reference: ShapingReference.line(
                [("fi", [])], size: size, extra: [.font: font]
            )
        )
        let glyph = try #require(line.runs.flatMap(\.glyphs).first
        {
            $0.displayRange == 0..<2
        })
        #expect(glyph.sources.map(\.fragment.paragraphRange) == [0..<1, 2..<3])
        #expect(glyph.sources.map(\.fragment.runIndex) == [0, 2])
        #expect(line.runs.flatMap(\.glyphs).count == 1)
        #expect(line.display.intervals[1].atom.kind == .suppressedSoftHyphen)
        #expect(line.display.intervals[1].range == 1..<1)
        try ShapingEvidence.write(
            "hidden-ligature-" + String(Int(size)), lines: [control, line]
        )
    }
}
