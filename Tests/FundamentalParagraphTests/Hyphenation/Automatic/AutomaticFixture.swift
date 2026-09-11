@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import FundamentalDocument

@MainActor
enum AutomaticFixture
{
    static func collection(
        _ source: ParagraphWordSource,
        language: NativeWordLanguage = .english
    ) throws -> ParagraphHyphens
    {
        try ParagraphHyphens(
            NativeParagraphWords(source: source, language: language),
            catalog: OwnedFixture.catalog()
        )
    }

    static func text(_ text: String) throws -> ParagraphHyphens
    {
        try collection(ExplicitFixture.source(text))
    }

    static func line(
        _ collection: ParagraphHyphens, range: Range<Int>,
        end: HyphenatedLineEnd = .unbroken, size: Double = 18
    ) throws -> HyphenatedShapedLine
    {
        try HyphenatedShapedLine(collection, range: range, end: end)
        {
            try ShapingFixture.attributes($0, size: size)
        }
    }
}
