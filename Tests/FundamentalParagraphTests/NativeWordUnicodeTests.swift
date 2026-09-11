@testable import FundamentalParagraph
import FundamentalNativeParagraph
import Testing

@Suite
struct NativeWordUnicodeTests
{
    @Test(arguments: [false, true])
    func russianWordKeepsOriginalCoordinatesAcrossRunSeams(
        _ decomposed: Bool
    ) throws
    {
        let left = decomposed ? "раи" : "ра"
        let right = decomposed ? "\u{306}он" : "йон"
        let source = try WordFixture.source([
            WordFixture.run("👩‍💻 "),
            WordFixture.run(left, traits: [.strong]),
            WordFixture.run(right, traits: [.emphasis]),
            WordFixture.run("!")
        ], language: "ru_RU")
        let words = try WordEvidence.observe(
            decomposed ? "russian-nfd" : "russian-nfc",
            source: source, language: .russian
        )
        let selected = try words.matching(6..<6)
        let end = decomposed ? 12 : 11
        let seam = decomposed ? 9 : 8
        #expect(selected.map(\.resolution.range) == [6..<end])
        let first = try #require(selected.first)
        let scope = try WordFixture.resolved(first.resolution)
        #expect(scope.fragments == [
            .init(runIndex: 1, paragraphRange: 6..<seam,
                  runRange: 0..<(seam - 6)),
            .init(runIndex: 2, paragraphRange: seam..<end, runRange: 0..<3)
        ])
        #expect(scope.language.value == "ru_RU")
        let expected = decomposed ? "👩‍💻 раи\u{306}он!" : "👩‍💻 район!"
        #expect(words.returnedUTF16 == Array(expected.utf16))
    }

    @Test
    func preservesTheObservedUnsafeNativeTokenAsARefusal() throws
    {
        let text = "alpha\u{A0}beta no\u{2060}break a\u{200D}b"
        let words = try WordEvidence.observe(
            "unsafe-joiner", source: WordFixture.source([WordFixture.run(text)])
        )
        let expected = WordScopeResolution.refused(20..<21, [.graphemeBoundary])
        #expect(words.observations.contains { $0.resolution == expected })
        #expect(words.returnedUTF16 == Array(text.utf16))
        #expect(try words.matching(20..<22).map(\.resolution) == [expected])
    }

    @Test
    func nativeTokensRetainSimultaneousSemanticRefusals() throws
    {
        let english = try WordFixture.language("en_US")
        let russian = try WordFixture.language("ru_RU")
        let source = try WordFixture.source([
            WordFixture.run("extra"),
            WordFixture.scoped("ordinary", .language(russian),
                               traits: [.inlineCode])
        ])
        let words = try WordEvidence.observe("scope-conflict", source: source)
        #expect(words.observations.map(\.resolution) == [
            .refused(0..<13, [
                .incompatibleLanguages([english, russian]), .inlineCode([1])
            ])
        ])
    }
}
