@testable import FundamentalParagraph
import Testing

@Suite
struct ExplicitSemanticTests
{
    @Test
    func wholeWordSemanticsCannotBeBypassedAtTheMarker() throws
    {
        let other = try WordFixture.language("en_GB")
        let sources = [
            try WordFixture.source([
                WordFixture.run("extra", traits: [.inlineCode]),
                WordFixture.run("\u{AD}ordinary")
            ]),
            try WordFixture.source([
                WordFixture.run("extra"),
                WordFixture.run("\u{AD}", traits: [.inlineCode]),
                WordFixture.run("ordinary")
            ]),
            try WordFixture.source([
                WordFixture.run("extra\u{AD}"),
                WordFixture.scoped("ordinary", .language(other))
            ])
        ]
        for (index, source) in sources.enumerated()
        {
            let collection = ExplicitParagraphHyphens(source)
            #expect(collection.groups.map(\.range) == [0..<14])
            #expect(collection.records.map(\.outcome)
                == [.refused(.sourceScope)])
            #expect(ExplicitFixture.indices(collection).isEmpty)
            try ExplicitEvidence.write(
                "semantic-\(index)", collection: collection
            )
        }
    }

    @Test(arguments: ["en-US", "zz_ZZ", "ru"])
    func unsupportedLocalesRemainExplicit(_ language: String) throws
    {
        let source = try ExplicitFixture.source(
            "extra\u{AD}ordinary", language: language
        )
        let collection = ExplicitParagraphHyphens(source)
        #expect(collection.records.map(\.outcome) == [
            .refused(.unsupportedLanguage(language))
        ])
        try ExplicitEvidence.write(
            "unsupported-" + language, collection: collection
        )
    }

    @Test
    func scalarInventoryIncludesMarksInsideNonWordCharacters() throws
    {
        let text = "👩‍💻 (a\u{AD}bc) .\u{200D} /"
        let collection = ExplicitParagraphHyphens(
            try ExplicitFixture.source(text)
        )
        let expected: [SourceHyphenationMark] = [
            .init(mark: .zeroWidthJoiner, range: 2..<3),
            .init(mark: .softHyphen, range: 8..<9),
            .init(mark: .zeroWidthJoiner, range: 14..<15)
        ]
        #expect(collection.marks == expected)
        #expect(collection.records.map(\.mark) == expected)
        #expect(ExplicitFixture.indices(collection) == [1])
        try ExplicitEvidence.write("mark-inventory", collection: collection)
    }
}
