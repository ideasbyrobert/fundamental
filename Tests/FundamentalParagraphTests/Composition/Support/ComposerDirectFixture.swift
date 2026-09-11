@testable import FundamentalNativeParagraph
import Testing

@MainActor
enum ComposerDirectFixture
{
    static func compose(
        _ original: ParagraphComposition, width: Double
    ) throws -> StagedParagraphComposition
    {
        var resolved = 0
        let result = try StagedParagraphComposition(
            original.collection, width: width
        )
        {
            run in
            #expect(run == original.collection.source.paragraph.runs[resolved])
            defer
            {
                resolved += 1
            }
            return original.attributes.values[resolved]
        }
        #expect(resolved == original.collection.source.paragraph.runs.count)
        return result
    }
}
