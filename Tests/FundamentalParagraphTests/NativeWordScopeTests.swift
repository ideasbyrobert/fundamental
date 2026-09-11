@testable import FundamentalParagraph
import FundamentalNativeParagraph
import FundamentalDocument
import Testing

@Suite
struct NativeWordScopeTests
{
    static let allowedTraits: [Set<SemanticInlineTrait>] = [
        [.strong], [.emphasis], [.underline], [.strikethrough],
        [.superscript], [.subscriptText], [.strong, .emphasis]
    ]

    @Test
    func observesTheUnsplitReference() throws
    {
        let source = try WordFixture.source([WordFixture.run("extraordinary")])
        let words = try WordEvidence.observe("unsplit", source: source)
        #expect(words.observations.map(\.resolution.range) == [0..<13])
        let first = try #require(words.observations.first)
        let scope = try WordFixture.resolved(first.resolution)
        #expect(scope.fragments == [
            .init(runIndex: 0, paragraphRange: 0..<13, runRange: 0..<13)
        ])
    }

    @Test(arguments: 1..<13, allowedTraits)
    func formattingPartitionsPreserveWholeNativeWords(
        _ boundary: Int, _ traits: Set<SemanticInlineTrait>
    ) throws
    {
        let text = Array("extraordinary")
        let left = String(text[..<boundary])
        let right = String(text[boundary...])
        let source = try WordFixture.source([
            WordFixture.run(left, traits: traits), WordFixture.run(right)
        ])
        let names = traits.map(\.rawValue).sorted().joined(separator: "-")
        let words = try WordEvidence.observe(
            "split-\(boundary)-\(names)", source: source
        )
        let reference = try NativeParagraphWords(
            source: WordFixture.source([WordFixture.run("extraordinary")]),
            language: .english
        )
        #expect(words.observations.map(\.resolution.range) == [0..<13])
        #expect(words.observations.map(\.flags)
            == reference.observations.map(\.flags))
        let first = try #require(words.observations.first)
        let scope = try WordFixture.resolved(first.resolution)
        #expect(scope.fragments == [
            .init(runIndex: 0, paragraphRange: 0..<boundary,
                  runRange: 0..<boundary),
            .init(runIndex: 1, paragraphRange: boundary..<13,
                  runRange: 0..<(13 - boundary))
        ])
        #expect(source.paragraph.runs[0].traits == traits)
        #expect(scope.language.value == "en_US")
    }

    @Test
    func differentLinkDestinationsRemainWordContent() throws
    {
        let first = try #require(SemanticLinkDestination("https://example.com"))
        let second = try #require(SemanticLinkDestination(
            "https://example.org"
        ))
        let language = try WordFixture.language("en_GB")
        let source = try WordFixture.source([
            WordFixture.scoped("extra", .link(first)),
            WordFixture.scoped("ordinary", .linkAndLanguage(
                link: second, language: language
            ))
        ], language: "en_GB")
        let words = try WordEvidence.observe("linked-word", source: source)
        #expect(words.observations.map(\.resolution.range) == [0..<13])
        let observed = try #require(words.observations.first)
        let scope = try WordFixture.resolved(observed.resolution)
        #expect(scope.fragments.map(\.runIndex) == [0, 1])
        #expect(scope.language.value == "en_GB")
    }
}
