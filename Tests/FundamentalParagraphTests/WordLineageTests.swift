@testable import FundamentalParagraph
import FundamentalNativeParagraph
import FundamentalDocument
import Testing

@Suite
struct WordLineageTests
{
    @Test
    func clipsOnlyRunFragmentsAndRetainsTheWholeWord() throws
    {
        let link = try #require(SemanticLinkDestination("https://example.com"))
        let value = try WordFixture.source([
            WordFixture.run("(extra", traits: [.strong]),
            WordFixture.scoped("ordin", .link(link), traits: [.emphasis]),
            WordFixture.run("ary!)", traits: [.underline])
        ])
        let scope = try WordFixture.resolved(value.resolve(1..<14))
        #expect(scope.range == 1..<14)
        #expect(scope.language.value == "en_US")
        #expect(scope.fragments == [
            .init(runIndex: 0, paragraphRange: 1..<6, runRange: 1..<6),
            .init(runIndex: 1, paragraphRange: 6..<11, runRange: 0..<5),
            .init(runIndex: 2, paragraphRange: 11..<14, runRange: 0..<3)
        ])
        var recovered: [UInt16] = []
        for fragment in scope.fragments
        {
            let run = value.paragraph.runs[fragment.runIndex]
            recovered += Array(run.text.utf16)[fragment.runRange]
        }
        #expect(recovered == Array("extraordinary".utf16))
    }

    @Test
    func anEmptyForeignCodeRunDoesNotOccupyAWord() throws
    {
        let other = try WordFixture.language("ru_RU")
        let value = try WordFixture.source([
            WordFixture.run("extra"),
            WordFixture.scoped("", .language(other), traits: [.inlineCode]),
            WordFixture.run("ordinary")
        ])
        let scope = try WordFixture.resolved(value.resolve(0..<13))
        #expect(scope.fragments.map(\.runIndex) == [0, 2])
        #expect(scope.language.value == "en_US")
        #expect(value.paragraph.runs.count == 3)
    }

    @Test(arguments: ["no\u{2060}break", "soft\u{AD}ware", "со\u{2011}автор"])
    func sourceScopePreservesCharactersForLaterCandidatePolicy(
        _ text: String
    ) throws
    {
        let source = try WordFixture.source([WordFixture.run(text)])
        let range = 0..<text.utf16.count
        let scope = try WordFixture.resolved(source.resolve(range))
        #expect(scope.range == range)
        #expect(source.source.utf16 == Array(text.utf16))
    }
}
