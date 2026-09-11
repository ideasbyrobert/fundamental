@testable import FundamentalParagraph
import FundamentalNativeParagraph
import Testing

@Suite
struct WordCoordinateTests
{
    @Test(arguments: [-1..<3, 0..<4, 0..<Int.max])
    func refusesOutOfBoundsRanges(_ range: Range<Int>) throws
    {
        let source = try WordFixture.source([WordFixture.run("abc")])
        #expect(source.resolve(range) == .refused(range, [.invalidBounds]))
    }

    @Test(arguments: [0..<0, 1..<1, 3..<3])
    func refusesEmptyTokenRanges(_ range: Range<Int>) throws
    {
        let source = try WordFixture.source([WordFixture.run("abc")])
        #expect(source.resolve(range) == .refused(range, [.emptyRange]))
    }

    @Test(arguments: [0..<1, 1..<2, 1..<3])
    func refusesTheRetainedJoinerBoundary(_ range: Range<Int>) throws
    {
        let source = try WordFixture.source([WordFixture.run("a\u{200D}b")])
        #expect(source.resolve(range) == .refused(range, [.graphemeBoundary]))
    }

    @Test
    func completeEmojiAndCombiningCharactersRetainTheirCoordinates() throws
    {
        let source = try WordFixture.source([
            WordFixture.run("👩"), WordFixture.run("\u{200D}"),
            WordFixture.run("💻 e"), WordFixture.run("\u{301}")
        ])
        let emoji = try WordFixture.resolved(source.resolve(0..<5))
        #expect(emoji.fragments.map(\.paragraphRange) == [0..<2, 2..<3, 3..<5])
        let accent = try WordFixture.resolved(source.resolve(6..<8))
        #expect(accent.fragments.map(\.paragraphRange) == [6..<7, 7..<8])
        #expect(source.resolve(0..<2) == .refused(0..<2, [.graphemeBoundary]))
        #expect(source.resolve(6..<7) == .refused(6..<7, [.graphemeBoundary]))
    }
}
