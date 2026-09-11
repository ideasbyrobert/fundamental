import Foundation
import Testing

@testable import FundamentalNativeWrapping

@MainActor
@Suite("Exact native measurement ranges")
struct NativeWrappingRangeTests
{
    @Test("empty ranges never shape the remaining source")
    func emptyRanges() throws
    {
        let text = try #require(NativeWrappingText(
            NativeWrappingFixture.text("ab\r\nz")
        ))
        for offset in [0, 2, 4, 5]
        {
            let line = try #require(text.line(
                in: offset ..< offset, inlineOffset: 19
            ))
            #expect(line.native == nil)
            #expect(line.advance == 0 && line.trailingWhitespace == 0)
            #expect(line.range == offset ..< offset)
        }
        #expect(text.line(in: 3 ..< 3, inlineOffset: 0) == nil)
    }

    @Test("invalid source ranges and split graphemes are refused")
    func invalidRanges() throws
    {
        let text = try #require(NativeWrappingText(NativeWrappingFixture.text(
            "e\u{301}👩🏽‍💻\r\n"
        )))
        for range in [
            -1 ..< 0, 0 ..< Int.max, Int.min ..< Int.max,
            0 ..< 1, 1 ..< 2, 2 ..< 3, 10 ..< 11
        ]
        {
            #expect(text.line(in: range, inlineOffset: 0) == nil)
        }
        #expect(text.line(in: 0 ..< text.source.utf16.count,
                          inlineOffset: 0) != nil)
    }

    @Test("negative and nonfinite inline positions are refused")
    func invalidOffsets() throws
    {
        let text = try #require(NativeWrappingText(
            NativeWrappingFixture.text("a")
        ))
        for offset in [-1.0, .infinity, -.infinity, .nan]
        {
            #expect(text.line(in: 0 ..< 1, inlineOffset: offset) == nil)
            #expect(text.line(in: 0 ..< 0, inlineOffset: offset) == nil)
        }
    }

    @Test("canonically equivalent spellings retain different source units")
    func exactSpelling() throws
    {
        let composed = try #require(NativeWrappingText(
            NativeWrappingFixture.text("é")
        ))
        let decomposed = try #require(NativeWrappingText(
            NativeWrappingFixture.text(
            "e\u{301}"
        )))
        #expect(composed.source != decomposed.source)
        #expect(composed.source.utf16.count == 1)
        #expect(decomposed.source.utf16.count == 2)
    }
}
