@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
@MainActor
enum StagedFixture
{
    static func shortEnding() throws -> ParagraphComposition
    {
        let source = try AutomaticFixture.text("WWWWWWWWi")
        let pair = try AutomaticFixture.line(
            source, range: 0..<2
        ).measurement.advance
        let triple = try AutomaticFixture.line(
            source, range: 6..<9
        ).measurement.advance
        return try ParagraphFixture.compose(
            source, width: (pair + triple) / 2
        )
    }

    static func tie() throws -> ParagraphComposition
    {
        try ParagraphFixture.compose(
            AutomaticFixture.collection(
                ExplicitFixture.source("WW\u{AD}WWWWW", language: "zz_ZZ")
            ),
            width: 40
        )
    }
}
