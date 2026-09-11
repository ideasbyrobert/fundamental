@testable import FundamentalParagraph
import Foundation
import FundamentalWrapping
import Testing

@Suite
struct WordLookupTests
{
    @Test(arguments: [
        "extraordinary", "район", "раи\u{306}он", "a\u{301}\u{323}bc",
        "각", "\u{1100}\u{1161}\u{11A8}", "👩‍💻", "🇷🇺", "\u{301}ab",
        "ма\u{301}йор", "𝔽a"
    ])
    func agreesWithIndependentWholePrefixNormalization(_ word: String) throws
    {
        let prefix = "👩‍💻\n"
        let lower = prefix.utf16.count
        let upper = lower + word.utf16.count
        let original = prefix + word + "!"
        let source = WrappingSource(original)
        let lookup = try NormalizedWordLookup(
            source: source, range: lower..<upper
        )
        let indices = Array(word.indices) + [word.endIndex]
        let expected = indices.map
        {
            index in
            let start = String(word[..<index])
            return HyphenationBoundary(
                source: lower + start.utf16.count,
                lookup: start.precomposedStringWithCanonicalMapping.utf16.count
            )
        }
        #expect(lookup.boundaries == expected)
        for pair in expected
        {
            #expect(try lookup.sourceOffset(at: pair.lookup) == pair.source)
            #expect(try lookup.lookupOffset(at: pair.source) == pair.lookup)
        }
        #expect(lookup.sourceUTF16 == Array(word.utf16))
        #expect(source.utf16 == Array(original.utf16))
        #expect(lookup.text.utf16.elementsEqual(
            word.precomposedStringWithCanonicalMapping.utf16
        ))
    }

    @Test(arguments: [
        -1..<1, 0..<11, 0..<0, 1..<5, 6..<7, 7..<8, -3..<(-1)
    ])
    func refusesInvalidCompleteSourceRanges(_ range: Range<Int>) throws
    {
        let source = WrappingSource("👩‍💻 e\u{301} x")
        #expect(throws: HyphenationFailure.invalidRange(range))
        {
            try NormalizedWordLookup(source: source, range: range)
        }
    }

    @Test
    func unmappedCoordinatesRemainErrors() throws
    {
        let source = WrappingSource("👩‍💻 раи\u{306}он!")
        let lookup = try NormalizedWordLookup(source: source, range: 6..<12)
        for offset in [-1, 0, 5, 9, 13]
        {
            #expect(throws: HyphenationFailure.unmappedSource(offset))
            {
                try lookup.lookupOffset(at: offset)
            }
        }
        for offset in [-1, 6]
        {
            #expect(throws: HyphenationFailure.unmappedLookup(offset))
            {
                try lookup.sourceOffset(at: offset)
            }
        }
        let emoji = try NormalizedWordLookup(source: source, range: 0..<5)
        for offset in 1..<5
        {
            #expect(throws: HyphenationFailure.unmappedLookup(offset))
            {
                try emoji.sourceOffset(at: offset)
            }
        }
    }
}
