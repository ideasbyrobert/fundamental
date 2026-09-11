@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import AppKit
import CoreText
import FundamentalDocument
import Testing

@MainActor
enum ShapingFixture
{
    static func font(
        _ traits: Set<SemanticInlineTrait>, size: Double
    ) throws -> NSFont
    {
        let name: String
        switch (traits.contains(.strong), traits.contains(.emphasis))
        {
        case (false, false):
            name = "TimesNewRomanPSMT"
        case (true, false):
            name = "TimesNewRomanPS-BoldMT"
        case (false, true):
            name = "TimesNewRomanPS-ItalicMT"
        case (true, true):
            name = "TimesNewRomanPS-BoldItalicMT"
        }
        let font = try #require(NSFont(name: name, size: size))
        #expect(font.fontName == name)
        return font
    }

    static func attributes(
        _ run: SemanticRun, size: Double
    ) throws -> [NSAttributedString.Key: Any]
    {
        var result: [NSAttributedString.Key: Any] = [
            .font: try font(run.traits, size: size), .ligature: 1
        ]
        if run.traits.contains(.underline)
        {
            result[.underlineStyle] = NSUnderlineStyle.single.rawValue
        }
        if run.traits.contains(.strikethrough)
        {
            result[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        }
        if run.traits.contains(.superscript)
        {
            result[.baselineOffset] = size * 0.3
        }
        if run.traits.contains(.subscriptText)
        {
            result[.baselineOffset] = -size * 0.2
        }
        return result
    }

    static func line(
        _ collection: ExplicitParagraphHyphens,
        range: Range<Int>, end: ExplicitSliceEnd = .unbroken,
        offset: Double = 0, size: Double = 18
    ) throws -> ExplicitShapedLine
    {
        try ExplicitShapedLine(
            collection, range: range, end: end, inlineOffset: offset
        )
        {
            try attributes($0, size: size)
        }
    }

    static func collection(_ text: String) throws -> ExplicitParagraphHyphens
    {
        ExplicitParagraphHyphens(try ExplicitFixture.source(text))
    }
}
