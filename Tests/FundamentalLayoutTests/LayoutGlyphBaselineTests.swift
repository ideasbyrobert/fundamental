import CoreText
import Foundation
import Testing

@testable import FundamentalLayout

@MainActor
@Suite("Native glyph baseline conversion")
struct LayoutGlyphBaselineTests
{
    @Test("native positions enter owned glyph geometry exactly once")
    func nativePositions() throws
    {
        for fixture in try LayoutBaselineFixture.cases()
        {
            let native = CTLineGetGlyphRuns(fixture.line) as! [CTRun]
            #expect(native.count == fixture.runs.count)
            for (index, raw) in native.enumerated()
            {
                let count = CTRunGetGlyphCount(raw)
                var positions = [CGPoint](repeating: .zero, count: count)
                var advances = [CGSize](repeating: .zero, count: count)
                var glyphs = [CGGlyph](repeating: 0, count: count)
                let range = CFRange(location: 0, length: 0)
                CTRunGetPositions(raw, range, &positions)
                CTRunGetAdvances(raw, range, &advances)
                CTRunGetGlyphs(raw, range, &glyphs)
                let owned = fixture.runs[index]
                #expect(owned.glyphs.count == count)
                for (offset, glyph) in owned.glyphs.enumerated()
                {
                    #expect(glyph.identifier == UInt32(glyphs[offset]))
                    #expect(glyph.position.x
                            == fixture.baseline.x + positions[offset].x)
                    #expect(glyph.position.y
                            == fixture.baseline.y - positions[offset].y,
                            "\(fixture.name) glyph \(offset)")
                    #expect(glyph.advance.dx
                            == Double(advances[offset].width))
                    #expect(glyph.advance.dy
                            == -Double(advances[offset].height))
                    #expect(!glyph.sourceSlices.isEmpty)
                }
                let span = CTRunGetStringRange(raw)
                let text = (fixture.attributed.string as NSString).substring(
                    with: NSRange(location: span.location, length: span.length)
                )
                #expect(owned.sourceSlices.map(\.text).joined() == text)
            }
            try LayoutBaselineEvidence.write(fixture)
        }
    }
}
