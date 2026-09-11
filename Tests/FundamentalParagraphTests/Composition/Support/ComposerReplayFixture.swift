import FundamentalNativeParagraph
import Testing

@MainActor
enum ComposerReplayFixture
{
    static func paragraphs() throws -> [(String, ParagraphComposition)]
    {
        let values = try native() + sources() + styled()
        #expect(values.count == 30)
        #expect(Set(values.map(\.0)).count == 30)
        return values
    }
}
