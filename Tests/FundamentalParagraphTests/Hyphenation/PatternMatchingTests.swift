@testable import FundamentalParagraph
import Testing

@Suite
struct PatternMatchingTests
{
    static let patterns = "a1b ab2c b3c bc3 d3e d4e. .a2b"

    @Test
    func maximumWeightsAndAnchorsMatchTheHandComputedResult() throws
    {
        let dictionary = try PatternFixture.dictionary(
            "\\patterns{" + Self.patterns + "}"
        )
        let result = try dictionary.hyphenate("abcde")
        #expect(result.boundaries == [2, 3])
        #expect(result.match.weights == [0, 0, 2, 3, 3, 4, 0, 0])
        #expect(try dictionary.hyphenate("xabcde").boundaries == [2, 3, 4])
        #expect(try dictionary.hyphenate("abcdex").boundaries == [2, 3, 4])
    }

    @Test
    func repeatedKeysMergeByMaximumInEitherInsertionOrder() throws
    {
        let source = ["a1b", "a2b", "a5b"]
        let first = try PatternFixture.dictionary(
            "\\patterns{" + source.joined(separator: " ") + "}"
        )
        let second = try PatternFixture.dictionary(
            "\\patterns{" + source.reversed().joined(separator: " ") + "}"
        )
        let result = try first.hyphenate("abc")
        #expect(result.boundaries == [1])
        #expect(result.match.weights == [0, 0, 5, 0, 0, 0])
        #expect(try second.hyphenate("abc") == result)
    }

    @Test
    func explicitNoBreakExceptionsDoNotFallThroughToPatterns() throws
    {
        let dictionary = try PatternFixture.dictionary(
            #"\patterns{a1b b1c} \hyphenation{abc abcd a-bcde}"#
        )
        #expect(try dictionary.hyphenate("abc").boundaries.isEmpty)
        #expect(try dictionary.hyphenate("abc").basis == .exception)
        #expect(try dictionary.hyphenate("abc").match.work.edgeProbes == 0)
        #expect(try dictionary.hyphenate("abcde").boundaries == [1])
        #expect(throws: PatternFailure.conflictingException("abc"))
        {
            try PatternFixture.dictionary(
                #"\patterns{} \hyphenation{a-bc ab-c}"#
            )
        }
    }

    @Test
    func boundariesAndMinimaCountCompleteCharacters() throws
    {
        let source = "\\patterns{a1 a\u{301}1b b1c}"
        let dictionary = try PatternFixture.dictionary(source, left: 2)
        let result = try dictionary.hyphenate("a\u{301}bc")
        #expect(result.boundaries == [3])
        #expect(result.word.utf16.elementsEqual("a\u{301}bc".utf16))
        #expect(try dictionary.hyphenate("👩‍💻bc").boundaries == [6])
        #expect(try dictionary.hyphenate("").boundaries.isEmpty)
        let oversized = try PatternFixture.dictionary(
            source, left: Int.max, right: Int.max
        )
        #expect(try oversized.hyphenate("abc").boundaries.isEmpty)
        #expect(throws: PatternFailure.invalidMinima)
        {
            try PatternMinima(left: 0, right: 1)
        }
        #expect(throws: PatternFailure.invalidWord)
        {
            try dictionary.hyphenate("ab.cd")
        }
    }
}
