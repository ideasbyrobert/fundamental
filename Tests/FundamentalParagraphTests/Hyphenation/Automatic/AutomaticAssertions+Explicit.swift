@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import Testing

extension AutomaticAssertions
{
    static func explicitParity(
        _ unified: HyphenatedShapedLine, _ previous: ExplicitShapedLine
    ) throws
    {
        #expect(unified.display.units == previous.display.units)
        #expect(unified.measurement.advance == previous.measurement.advance)
        #expect(unified.measurement.trailingWhitespace
            == previous.measurement.trailingWhitespace)
        #expect(unified.runs.count == previous.runs.count)
        #expect(unified.display.body.slice.atoms
            == previous.display.slice.atoms)
        for (a, b) in zip(unified.runs, previous.runs)
        {
            #expect(a.range == b.range && a.status == b.status)
            #expect(a.matrix == b.matrix)
            #expect(a.font.postScript == b.font.postScript)
            #expect(a.font.unique == b.font.unique)
            #expect(a.font.version == b.font.version)
            #expect(a.font.pointSize == b.font.pointSize)
            #expect(a.font.symbolicTraits == b.font.symbolicTraits)
            #expect(a.font.matrix == b.font.matrix)
            #expect(a.font.variations == b.font.variations)
            #expect(a.glyphs.count == b.glyphs.count)
            for (x, y) in zip(a.glyphs, b.glyphs)
            {
                #expect(x.identifier == y.identifier)
                #expect(x.position == y.position && x.advance == y.advance)
                #expect(x.stringIndex == y.stringIndex)
                #expect(x.displayRange == y.displayRange)
                #expect(x.sources
                    == y.sources.map(HyphenatedGlyphSource.source))
            }
        }
    }
}
