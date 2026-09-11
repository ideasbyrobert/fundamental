@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import Testing

@MainActor
struct ParagraphNativeTests
{
    @Test func nativeEnglishRussianAndAuthoredInkRetainCanonicalText() throws
    {
        let cases = [
            ("english", "extraordinary", "en_US", 60.0),
            ("russian", "район", "ru_RU", 35.0),
            ("decomposed", "раи\u{306}он", "ru_RU", 35.0),
            ("authored", "re\u{AD}presentation", "en_US", 100.0),
            ("mixed", "a re\u{AD}presentation extraordinary word",
             "en_US", 100.0),
            ("emoji", "👩‍💻 extraordinary раи\u{306}он", "en_US", 65.0)
        ]
        for (name, text, language, width) in cases
        {
            let value = try AutomaticFixture.collection(
                ExplicitFixture.source(text, language: language),
                language: language == "ru_RU" ? .russian : .english
            )
            for size in [18.0, 36]
            {
                let result = try ParagraphFixture.compose(
                    value, width: width * size / 18, size: size
                )
                try ParagraphAssertions.verify(result)
                let lines = result.segments.flatMap(\.lines)
                if ["english", "russian", "decomposed"].contains(name)
                {
                    #expect(lines.contains
                    {
                        $0.ending.kind.rank == 3
                    })
                }
                if name == "authored"
                {
                    #expect(lines.contains
                    {
                        $0.ending.kind.rank == 2
                    })
                }
                try ParagraphEvidence.write(
                    "\(name)-\(Int(size))", result: result
                )
            }
        }
    }

    @Test func formattingSeamsAndDecomposedOwnersKeepTheirOriginalRuns() throws
    {
        let source = try WordFixture.source([
            WordFixture.run("👩‍💻 раи", traits: [.strong]),
            WordFixture.run("\u{306}", traits: [.emphasis]),
            WordFixture.run("он и "),
            WordFixture.run("", traits: [.underline]),
            WordFixture.run("район", traits: [.underline])
        ], language: "ru_RU")
        let value = try AutomaticFixture.collection(source, language: .russian)
        let result = try ParagraphFixture.compose(value, width: 36)
        try ParagraphAssertions.verify(result)
        #expect(result.collection.source.paragraph == source.paragraph)
        #expect(result.attributes.values.count == 5)
        #expect(result.segments.flatMap(\.lines).contains
        {
            $0.ending.kind.rank == 3
        })
        try ParagraphEvidence.write("formatting", result: result)
    }
}
