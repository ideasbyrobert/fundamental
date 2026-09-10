import Testing

@testable import FundamentalWrapping

@Suite("Checked wrapping source ranges")
struct WrappingSourceRangeTests
{
    let source = WrappingSource("e\u{301}👩🏽‍💻\r\nZ")

    @Test("all valid grapheme boundaries are addressable",
          arguments: [0, 2, 9, 11, 12])
    func boundaries(_ offset: Int)
    {
        #expect(source.isBoundary(offset))
        #expect(source.range(location: offset, length: 0) == offset ..< offset)
    }

    @Test("combining, surrogate, emoji and CRLF interiors are refused",
          arguments: [1, 3, 4, 5, 6, 7, 8, 10])
    func interiors(_ offset: Int)
    {
        #expect(!source.isBoundary(offset))
        #expect(source.range(location: offset, length: 0) == nil)
        #expect(source.substring(in: offset ..< offset) == nil)
        #expect(source.range(location: 0, length: offset) == nil)
    }

    @Test("native range arithmetic rejects invalid and extreme integers",
          arguments: [
              (-1, 0), (0, -1), (13, 0), (12, 1),
              (Int.min, 1), (Int.max, 0), (1, Int.max), (Int.max, Int.max)
          ])
    func invalidRange(_ location: Int, length: Int)
    {
        #expect(source.range(location: location, length: length) == nil)
    }

    @Test("admitted slices reproduce exact source units")
    func slices() throws
    {
        let accent = try #require(source.range(location: 0, length: 2))
        let emoji = try #require(source.range(location: 2, length: 7))
        let ending = try #require(source.range(location: 9, length: 2))
        #expect(source.substring(in: accent)?.utf16.elementsEqual(
            [101, 769]
        ) == true)
        #expect(source.substring(in: emoji)?.utf16.elementsEqual(
            "👩🏽‍💻".utf16
        ) == true)
        #expect(source.substring(in: ending)?.utf16.elementsEqual(
            [13, 10]
        ) == true)
        #expect(source.substring(in: -1 ..< 0) == nil)
        #expect(source.substring(in: 0 ..< Int.max) == nil)
        #expect(source.substring(in: 12 ..< 12) == "")
    }
}
