@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import AppKit
import CoreText
import FundamentalDocument

@MainActor
enum ShapingReference
{
    static func line(
        _ parts: [(String, Set<SemanticInlineTrait>)],
        size: Double = 18, offset: Double = 0,
        extra: [NSAttributedString.Key: Any] = [:]
    ) throws -> CTLine
    {
        let literal = NSMutableAttributedString(string: "")
        for (text, traits) in parts
        {
            var attributes = try ShapingFixture.attributes(
                WordFixture.run(text, traits: traits), size: size
            )
            attributes.merge(extra) { _, value in value }
            literal.append(NSAttributedString(
                string: text, attributes: attributes
            ))
        }
        return CTTypesetterCreateLineWithOffset(
            CTTypesetterCreateWithAttributedString(literal),
            CFRange(location: 0, length: literal.length), offset
        )
    }

    static func rawRuns(_ line: CTLine) -> [[String: Any]]
    {
        (CTLineGetGlyphRuns(line) as! [CTRun]).map
        {
            run in
            let count = CTRunGetGlyphCount(run)
            let range = CFRange(location: 0, length: count)
            var glyphs = [CGGlyph](repeating: 0, count: count)
            var indices = [CFIndex](repeating: 0, count: count)
            var positions = [CGPoint](repeating: .zero, count: count)
            var advances = [CGSize](repeating: .zero, count: count)
            CTRunGetGlyphs(run, range, &glyphs)
            CTRunGetStringIndices(run, range, &indices)
            CTRunGetPositions(run, range, &positions)
            CTRunGetAdvances(run, range, &advances)
            let attributes = CTRunGetAttributes(run) as NSDictionary
            let font = attributes[kCTFontAttributeName] as! CTFont
            return [
                "font": CTFontCopyPostScriptName(font) as String,
                "size": CTFontGetSize(font),
                "glyphs": glyphs, "indices": indices,
                "positions": positions.map { [$0.x, $0.y] },
                "advances": advances.map { [$0.width, $0.height] }
            ]
        }
    }
}
