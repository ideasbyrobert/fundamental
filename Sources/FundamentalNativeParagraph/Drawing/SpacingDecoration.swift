import AppKit
import CoreText

package struct SpacingDecoration: Sendable
{
    package enum Kind: String, Sendable
    {
        case underline
        case strikethrough
    }

    package let kind: Kind
    package let bounds: CGRect
    package let sources: [HyphenatedGlyphSource]

    static func make(
        attributes: [NSAttributedString.Key: Any], font: CTFont,
        baseline: Double, glyphs: [SpacedNativeGlyph],
        sources: [HyphenatedGlyphSource]
    ) throws -> [Self]
    {
        let styles: [(NSAttributedString.Key, Kind, Double)] = [
            (.underlineStyle, .underline, CTFontGetUnderlinePosition(font)),
            (.strikethroughStyle, .strikethrough, CTFontGetXHeight(font) * 0.5)
        ]
        let edges = glyphs.flatMap
        {
            [$0.position.x, $0.position.x + $0.advance.width]
        }
        guard let lower = edges.min(), let upper = edges.max()
        else
        {
            return []
        }
        let thickness = abs(CTFontGetUnderlineThickness(font))
        return try styles.compactMap
        {
            key, kind, offset in
            let value = (attributes[key] as? NSNumber)?.intValue ?? 0
            guard value == 0 || value == NSUnderlineStyle.single.rawValue
            else
            {
                throw NativeSpacingFailure.unsupportedDecoration
            }
            if value == 0
            {
                return nil
            }
            return Self(
                kind: kind,
                bounds: CGRect(
                    x: lower, y: baseline + offset - thickness * 0.5,
                    width: upper - lower, height: thickness
                ),
                sources: sources
            )
        }
    }
}
