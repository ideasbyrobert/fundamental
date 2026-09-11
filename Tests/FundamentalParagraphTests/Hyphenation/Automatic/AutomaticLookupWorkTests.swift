@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import Testing

@MainActor
@Suite
struct AutomaticLookupWorkTests
{
    @Test
    func repeatedProjectionsDoNotRepeatDictionaryLookup() throws
    {
        let source = try ExplicitFixture.source("extraordinary extraordinary")
        var calls = 0
        let value = try ParagraphHyphens(
            NativeParagraphWords(source: source, language: .english),
            catalog: OwnedFixture.catalog()
        )
        {
            dictionary, text in
            calls += 1
            return try dictionary.hyphenate(text)
        }
        #expect(calls == 2)
        #expect(value.inks.count == 8)
        var lines: [HyphenatedShapedLine] = []
        for _ in 0..<2
        {
            for index in value.inks.indices
            {
                let offset = value.inks[index].candidate.sourceOffset
                lines.append(try AutomaticFixture.line(
                    value, range: 0..<offset,
                    end: .automatic(value.selectAutomatic(index))
                ))
            }
        }
        #expect(calls == 2)
        try AutomaticEvidence.write(
            "lookup-work", collection: value, lines: lines,
            extra: ["dictionaryCalls": calls, "projections": lines.count]
        )
    }
}
