@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import CoreText
import Foundation
import Testing

@MainActor
enum AutomaticAssertions
{
    static func compare(
        _ line: HyphenatedShapedLine, text: String, reference: CTLine
    ) throws
    {
        #expect(line.display.units == Array(text.utf16))
        _ = try ExplicitFixture.reconstructed(line.display.body.slice)
        #expect(abs(line.measurement.advance - CTLineGetTypographicBounds(
            reference, nil, nil, nil
        )) < 0.000001)
        #expect(abs(line.measurement.trailingWhitespace
            - CTLineGetTrailingWhitespaceWidth(reference)) < 0.000001)
        #expect(try JSONSerialization.data(
            withJSONObject: line.runs.map(\.signature), options: .sortedKeys
        ) == JSONSerialization.data(
            withJSONObject: ShapingReference.rawRuns(reference),
            options: .sortedKeys
        ))
        let glyphs = line.runs.flatMap(\.glyphs)
        #expect(Set(glyphs.flatMap(\.displayRange))
            == Set(line.display.units.indices))
        for glyph in glyphs
        {
            try sources(
                line.display, range: glyph.displayRange, values: glyph.sources
            )
        }
    }

    static func sources(
        _ display: HyphenatedDisplay, range: Range<Int>,
        values: [HyphenatedGlyphSource]
    ) throws
    {
        var original: [ExplicitDisplayAtom] = []
        var generated: [AutomaticHyphenInk] = []
        for value in values
        {
            switch value
            {
            case let .source(atom): original.append(atom)
            case let .generated(ink): generated.append(ink)
            }
        }
        let upper = min(range.upperBound, display.body.units.count)
        if range.lowerBound < upper
        {
            try ShapingAssertions.sources(
                display.body, query: range.lowerBound..<upper, actual: original
            )
        }
        else
        {
            #expect(original.isEmpty)
        }
        if range.upperBound > display.body.units.count
        {
            guard case let .automatic(ink) = display.suffix
            else
            {
                Issue.record("Unexpected generated source")
                return
            }
            #expect(generated == [ink])
            #expect(ink.sourceRange.isEmpty)
            #expect(ink.sourceRange.lowerBound == display.body.slice.range
                .upperBound)
        }
        else
        {
            #expect(generated.isEmpty)
        }
    }
}
