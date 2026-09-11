import AppKit
import CoreText
import Testing

@testable import FundamentalLayout

@MainActor
@Suite("Contextual Reader shaping")
struct LayoutContextualShapingTests
{
    @Test("wrapped indented tabs preserve source and glyph correspondence")
    func tabs() throws
    {
        let fixture = try LayoutContextualFixture()
        let source = fixture.attributed.string
        #expect(fixture.lines.map(\.text).joined() == source)
        let tab = try #require(fixture.lines.first { $0.text == "a\t" })
        let isolated = CTLineCreateWithAttributedString(
            fixture.attributed.attributedSubstring(from: NSRange(
                location: 10, length: 2
            ))
        )
        let isolatedAdvance = CTLineGetTypographicBounds(
            isolated, nil, nil, nil
        )
        let positions = tab.caretStops.map(\.position.x)
        let nativeAdvance = try #require(positions.max())
            - #require(positions.min())
        #expect(abs(isolatedAdvance - nativeAdvance) > 0.5)
        var offset = 0
        for line in fixture.lines
        {
            #expect(line.sourceSlices.map(\.text).joined() == line.text)
            let end = offset + line.text.utf16.count
            for caret in line.caretStops
            {
                #expect(caret.sourcePoint == .block(
                    blockID: LayoutFixture.blockID(0),
                    utf16Offset: offset + caret.utf16Offset
                ))
            }
            for run in line.glyphRuns
            {
                for slice in run.sourceSlices
                {
                    #expect(slice.range.lowerBound >= offset)
                    #expect(slice.range.upperBound <= end)
                }
                for glyph in run.glyphs
                {
                    #expect(glyph.position.x >= line.frame.minX - 0.5)
                    #expect(glyph.position.x + glyph.advance.dx
                        <= line.frame.maxX + 0.5)
                }
            }
            offset = end
        }
        #expect(offset == source.utf16.count)
    }

    @Test("outer translation does not change contextual tab shaping")
    func translation() throws
    {
        let original = try LayoutContextualFixture().lines
        let shifted = try LayoutContextualFixture(originX: 37).lines
        #expect(shifted.count == original.count)
        for (first, second) in zip(original, shifted)
        {
            #expect(first.text == second.text)
            #expect(first.sourceSlices == second.sourceSlices)
            #expect(abs(first.frame.minX + 37 - second.frame.minX) < 0.001)
            for (a, b) in zip(first.glyphRuns, second.glyphRuns)
            {
                #expect(a.font == b.font && a.sourceSlices == b.sourceSlices)
                for (x, y) in zip(a.glyphs, b.glyphs)
                {
                    #expect(x.identifier == y.identifier)
                    #expect(abs(x.position.x + 37 - y.position.x) < 0.001)
                }
            }
        }
    }
}
