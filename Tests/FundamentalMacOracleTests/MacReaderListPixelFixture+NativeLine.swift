import AppKit
import CoreText
import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacReaderListPixelFixture
{
    static func nativeLine(_ batch: PresentationGlyphBatch) throws -> CTLine
    {
        guard case let .listMarker(marker) = batch.source
        else { throw MacOracleTestFailure.admission }
        let font = try #require(MacAdmittedFont(
            batch.font, sourceText: marker.label
        ))
        let space = try #require(MacAdmittedColorSpace(batch.color.colorSpace))
        let color = try #require(MacAdmittedColor(
            batch.color, colorSpace: space
        ))
        let value = NSAttributedString(string: marker.label, attributes: [
            NSAttributedString.Key(kCTFontAttributeName as String): font.native,
            NSAttributedString.Key(kCTForegroundColorAttributeName as String):
                color.graphics
        ])
        let line = CTLineCreateWithAttributedString(value)
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        var glyphs: [UInt32] = []
        for run in runs
        {
            var identifiers = [CGGlyph](
                repeating: 0, count: CTRunGetGlyphCount(run)
            )
            CTRunGetGlyphs(run, CFRange(location: 0, length: 0), &identifiers)
            glyphs += identifiers.map(UInt32.init)
        }
        #expect(glyphs == batch.glyphs.map(\.identifier))
        return line
    }
}
