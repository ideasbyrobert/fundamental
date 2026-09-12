import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

@MainActor
@Suite("Original document Find and Replace")
struct WritingFindTests
{
    static func results(
        _ query: String, in text: String, caseSensitive: Bool = false
    ) throws -> WritingFindResults
    {
        let source = try WritingTestDocument(text).projection()
        let query = try #require(WritingFindQuery(query,
                                                  caseSensitive: caseSensitive))
        return WritingFindResults(query, in: source)
    }

    @Test("literal punctuation and Unicode case matching retain source ranges")
    func literalAndCase() throws
    {
        #expect(try Self.results("[a]", in: "[a] a A").ranges == [
            NSRange(location: 0, length: 3)
        ])
        #expect(try Self.results("мир", in: "Мир мир").ranges == [
            NSRange(location: 0, length: 3), NSRange(location: 4, length: 3)
        ])
        #expect(try Self.results("мир", in: "Мир мир", caseSensitive: true)
            .ranges == [NSRange(location: 4, length: 3)])
    }

    @Test("canonically equivalent accents keep their original UTF-16 lengths")
    func equivalentSpelling() throws
    {
        #expect(try Self.results("é", in: "e\u{301} é").ranges == [
            NSRange(location: 0, length: 2), NSRange(location: 3, length: 1)
        ])
        #expect(try Self.results("👩", in: "👨‍👩‍👧‍👦 👩").ranges == [
            NSRange(location: 12, length: 2)
        ])
        #expect(try Self.results("e", in: "e\u{301}").ranges.isEmpty)
    }

    @Test("empty and multiline queries are refused without searching",
          arguments: ["", "a\nb", "\r", "\u{2028}", "\u{2029}"])
    func refusedQuery(_ text: String) throws
    {
        #expect(WritingFindQuery(text, caseSensitive: false) == nil)
    }

    @Test("navigation advances from selection and wraps in both directions")
    func navigation() throws
    {
        let results = try Self.results("cat", in: "cat dog cat")
        let first = NSRange(location: 0, length: 3)
        let last = NSRange(location: 8, length: 3)
        #expect(results.next(from: NSRange(location: 0, length: 0),
                             backwards: false) == first)
        #expect(results.next(from: first, backwards: false) == last)
        #expect(results.next(from: last, backwards: false) == first)
        #expect(results.next(from: first, backwards: true) == last)
        #expect(results.next(from: last, backwards: true) == first)
        #expect(try Self.results("absent", in: "cat").next(
            from: first, backwards: false
        ) == nil)
    }
}
