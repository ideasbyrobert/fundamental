import Testing

@testable import FundamentalWrapping

@Suite("Hard source lines")
struct WrappingSourceLineTests
{
    static let endings: [(String, WrappingLineEnding, [UInt16])] = [
        ("\n", .lineFeed, [10]),
        ("\r", .carriageReturn, [13]),
        ("\r\n", .carriageReturnLineFeed, [13, 10]),
        ("\u{85}", .nextLine, [133]),
        ("\u{B}", .verticalTab, [11]),
        ("\u{C}", .formFeed, [12]),
        ("\u{2028}", .lineSeparator, [8232]),
        ("\u{2029}", .paragraphSeparator, [8233])
    ]

    @Test("each ending retains its spelling and terminal empty line",
          arguments: endings)
    func ending(
        _ text: String, kind: WrappingLineEnding, units: [UInt16]
    ) throws
    {
        let source = WrappingSource("A" + text)
        #expect(source.lines.count == 2)
        let first = try #require(source.lines.first)
        let last = try #require(source.lines.last)
        #expect(first.contentRange == 0 ..< 1)
        #expect(first.endingRange == 1 ..< 1 + units.count)
        #expect(first.ending == kind)
        #expect(Array(source.utf16[first.endingRange]) == units)
        #expect(last.contentRange == 1 + units.count ..< 1 + units.count)
        #expect(last.endingRange == last.contentRange)
        #expect(last.ending == nil)
    }

    @Test("consecutive endings preserve every empty source line")
    func emptyLines()
    {
        let source = WrappingSource("\n\r\n\r")
        #expect(source.lines.map(\.contentRange) == [
            0 ..< 0, 1 ..< 1, 3 ..< 3, 4 ..< 4
        ])
        #expect(source.lines.map(\.endingRange) == [
            0 ..< 1, 1 ..< 3, 3 ..< 4, 4 ..< 4
        ])
        #expect(source.lines.map(\.ending) == [
            .lineFeed, .carriageReturnLineFeed, .carriageReturn, nil
        ])
    }

    @Test("CRLF ownership follows Unicode text rather than scalar counting")
    func combinedText()
    {
        let source = WrappingSource("e\u{301}👩🏽‍💻\r\nZ")
        #expect(source.lines.map(\.contentRange) == [0 ..< 9, 11 ..< 12])
        #expect(source.lines.map(\.endingRange) == [9 ..< 11, 12 ..< 12])
        #expect(source.lines.map(\.ending) == [.carriageReturnLineFeed, nil])
        #expect(source.graphemeBoundaries == [0, 2, 9, 11, 12])
    }
}
