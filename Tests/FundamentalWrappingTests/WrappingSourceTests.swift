import Testing

@testable import FundamentalWrapping

@Suite("Exact wrapping source")
struct WrappingSourceTests
{
    @Test("empty source retains its sole empty line and boundary")
    func emptySource() throws
    {
        let source = WrappingSource("")
        #expect(source.utf16.isEmpty)
        #expect(source.graphemeBoundaries == [0])
        let line = try #require(source.lines.first)
        #expect(source.lines.count == 1)
        #expect(line.contentRange == 0 ..< 0)
        #expect(line.endingRange == 0 ..< 0)
        #expect(line.ending == nil)
        #expect(source.substring(in: line.range) == "")
    }

    @Test("equality distinguishes canonically equivalent spellings")
    func exactEquality()
    {
        let composed = WrappingSource("é")
        let decomposed = WrappingSource("e\u{301}")
        #expect(composed.text == decomposed.text)
        #expect(composed != decomposed)
        #expect(Set([composed, decomposed, WrappingSource("é")]).count == 2)
        #expect(composed.utf16 == [233])
        #expect(decomposed.utf16 == [101, 769])
    }

    @Test("tabs and discretionary characters remain source content")
    func sourceWhitespace() throws
    {
        let text = "\t \u{A0}\u{200B}\u{2060}\u{AD}"
        let source = WrappingSource(text)
        let line = try #require(source.lines.first)
        #expect(source.lines.count == 1)
        #expect(line.contentRange == 0 ..< 6)
        #expect(line.ending == nil)
        #expect(source.utf16 == [9, 32, 160, 8203, 8288, 173])
        #expect(source.substring(in: line.range)?.utf16.elementsEqual(
            text.utf16
        ) == true)
    }
}
