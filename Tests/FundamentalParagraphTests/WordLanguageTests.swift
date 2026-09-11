@testable import FundamentalParagraph
import FundamentalNativeParagraph
import FundamentalDocument
import Testing

@Suite
struct WordLanguageTests
{
    @Test
    func explicitAndInheritedLanguageHaveTheSameEffectiveScope() throws
    {
        let language = try WordFixture.language("en_GB")
        let link = try #require(SemanticLinkDestination("https://example.com"))
        let source = try WordFixture.source([
            WordFixture.run("ex"),
            WordFixture.scoped("tra", .link(link)),
            WordFixture.scoped("ordin", .language(language)),
            WordFixture.scoped("ary", .linkAndLanguage(
                link: link, language: language
            ))
        ], language: "en_GB")
        let scope = try WordFixture.resolved(source.resolve(0..<13))
        #expect(scope.language.value.utf16.elementsEqual("en_GB".utf16))
        #expect(scope.fragments.map(\.runIndex) == [0, 1, 2, 3])
        #expect(source.spans.allSatisfy { $0.language == language })
    }

    @Test(arguments: ["en_GB", "en-US", "ru_RU"])
    func differentExactLanguagesReceiveAnExplicitOutcome(
        _ spelling: String
    ) throws
    {
        let first = try WordFixture.language("en_US")
        let second = try WordFixture.language(spelling)
        let source = try WordFixture.source([
            WordFixture.run("extra"),
            WordFixture.scoped("ordinary", .language(second))
        ])
        #expect(source.resolve(0..<13) == .refused(
            0..<13, [.incompatibleLanguages([first, second])]
        ))
        #expect(source.spans[1].language.value.utf16.elementsEqual(
            spelling.utf16
        ))
    }

    @Test
    func canonicalEquivalenceDoesNotEraseLanguageSourceSpelling() throws
    {
        let first = try WordFixture.language("é")
        let second = try WordFixture.language("e\u{301}")
        let source = try WordFixture.source([
            WordFixture.scoped("extra", .language(first)),
            WordFixture.scoped("ordinary", .language(second))
        ])
        #expect(source.resolve(0..<13) == .refused(
            0..<13, [.incompatibleLanguages([first, second])]
        ))
    }
}
