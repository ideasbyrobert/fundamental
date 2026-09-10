import Testing

@testable import FundamentalWrapping

@Suite("Wrapping source reconstruction")
struct WrappingSourceCorpusTests
{
    @Test("hard lines partition exact source independently of script",
          arguments: [
              "", "\n\r\n\r", "plain source",
              "a\nb\rc\r\nd\u{85}e\u{B}f\u{C}g\u{2028}h\u{2029}",
              "Русские слова\r\nи переносы",
              "אבג\tword\u{2028}العربية",
              "e\u{301}👩🏽‍💻\r\n\u{301}Z",
              "🇦🇲🇫🇷\n\u{1100}\u{1161}",
              "👨‍👩‍👧‍👦\u{2029}🏳️‍🌈",
              "\0\u{AD}\u{200B}\u{2060}\t "
          ])
    func reconstruction(_ text: String) throws
    {
        let source = WrappingSource(text)
        var position = 0
        var collected: [UInt16] = []
        for line in source.lines
        {
            #expect(line.contentRange.lowerBound == position)
            #expect(line.contentRange.upperBound == line.endingRange.lowerBound)
            #expect(source.isBoundary(line.range.lowerBound))
            #expect(source.isBoundary(line.range.upperBound))
            let spelling = try #require(source.substring(in: line.range))
            collected += spelling.utf16
            position = line.range.upperBound
        }
        #expect(position == text.utf16.count)
        #expect(collected.elementsEqual(text.utf16))
        #expect(source.text.utf16.elementsEqual(text.utf16))
        #expect(source.utf16.elementsEqual(text.utf16))
    }

    @Test("flags, family emoji and Hangul clusters remain indivisible",
          arguments: [
              ("🇦🇲🇫🇷", [0, 4, 8]),
              ("👨‍👩‍👧‍👦", [0, 11]),
              ("\u{1100}\u{1161}", [0, 2])
          ])
    func clusters(_ text: String, boundaries: [Int])
    {
        let source = WrappingSource(text)
        #expect(source.graphemeBoundaries == boundaries)
        for offset in 0 ... source.utf16.count
        {
            #expect(source.isBoundary(offset) == boundaries.contains(offset))
        }
    }

    @Test("large source retains exact terminal and distant ranges")
    func largeSource() throws
    {
        let text = String(repeating: "x", count: 1_048_576) + "\r\n"
        let source = WrappingSource(text)
        #expect(source.utf16.count == 1_048_578)
        #expect(source.graphemeBoundaries.count == 1_048_578)
        #expect(source.lines.count == 2)
        let range = try #require(source.range(
            location: 1_048_574, length: 4
        ))
        #expect(source.substring(in: range)?.utf16.elementsEqual(
            [120, 120, 13, 10]
        ) == true)
        #expect(!source.isBoundary(1_048_577))
        #expect(source.isBoundary(1_048_578))
    }
}
