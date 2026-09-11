@testable import FundamentalParagraph
import FundamentalNativeParagraph
import Testing

@Suite
struct WordProtectionTests
{
    @Test
    func reportsCodeAndLanguageConflictsTogether() throws
    {
        let english = try WordFixture.language("en_US")
        let russian = try WordFixture.language("ru_RU")
        let source = try WordFixture.source([
            WordFixture.run("extra"),
            WordFixture.scoped(
                "ordinary", .language(russian), traits: [.inlineCode]
            )
        ])
        #expect(source.resolve(0..<13) == .refused(0..<13, [
            .incompatibleLanguages([english, russian]), .inlineCode([1])
        ]))
    }

    @Test
    func adjacentCodeDoesNotProtectAnUnrelatedWord() throws
    {
        let source = try WordFixture.source([
            WordFixture.run("code", traits: [.inlineCode]),
            WordFixture.run(" extraordinary")
        ])
        let scope = try WordFixture.resolved(source.resolve(5..<18))
        #expect(scope.fragments == [
            .init(runIndex: 1, paragraphRange: 5..<18, runRange: 1..<14)
        ])
        #expect(source.resolve(0..<4) == .refused(0..<4, [.inlineCode([0])]))
    }

    @Test(arguments: ["\n", "\r\n", "\u{2028}", "\u{2029}"])
    func aTokenCannotSpanAHardEnding(_ ending: String) throws
    {
        let source = try WordFixture.source([
            WordFixture.run("first" + ending + "second")
        ])
        let end = 5 + ending.utf16.count
        let range = 0..<(end + 6)
        #expect(source.resolve(range) == .refused(
            range, [.hardEndings([5..<end])]
        ))
        let scope = try WordFixture.resolved(source.resolve(end..<(end + 6)))
        #expect(scope.range == end..<(end + 6))
    }
}
