@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
enum ParagraphFixture
{
    static func cache(_ value: ParagraphHyphens) throws -> ParagraphEdgeCache
    {
        let line = try #require(value.source.source.lines.first)
        #expect(value.source.source.lines.count == 1)
        return ParagraphEdgeCache(
            collection: value,
            candidates: try ParagraphBreakSet(value, line: line),
            attributes: try ParagraphAttributes(value.source)
            {
                try ShapingFixture.attributes($0, size: 18)
            }
        )
    }

    static func compose(
        _ value: ParagraphHyphens, width: Double, size: Double = 18
    ) throws -> ParagraphComposition
    {
        try ParagraphComposition(legacy:value, width: width)
        {
            try ShapingFixture.attributes($0, size: size)
        }
    }
}
