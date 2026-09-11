import Testing

@testable import FundamentalDocument
@testable import FundamentalLayout

@Suite("Reader consumes positioned code plans")
struct LayoutPlannedCodeTests
{
    @MainActor
    @Test("hard endings and final empty lines retain visible source carets")
    func hardLines() throws
    {
        let text = "\n\r\r\n\u{85}\u{b}\u{c}\u{2028}\u{2029}"
        let lines = try LayoutPlannedCodeFixture.lines([
            LayoutFixture.direct(text)
        ], width: 120)
        #expect(lines.map(\.text) == ["\n", "\r", "\r\n", "\u{85}",
            "\u{b}", "\u{c}", "\u{2028}", "\u{2029}", ""])
        #expect(lines.allSatisfy { $0.frame.size.height > 0 })
        #expect(Set(lines.map(\.baseline.y)).count == lines.count)
        #expect(lines.last?.firstCaretStop.sourcePoint == .block(
            blockID: LayoutFixture.blockID(0), utf16Offset: text.utf16.count
        ))
    }

    @MainActor
    @Test("all Unicode carets and complete whitespace advances remain in view")
    func visibleCarets() throws
    {
        let corpus = [
            String(repeating: " ", count: 40),
            "alpha" + String(repeating: " ", count: 40),
            "\talpha\tbeta\tgamma\t",
            "let שלום = \"مرحبا мир 👩🏽‍💻 e\u{301}\"\r\n"
        ]
        for text in corpus
        {
            for size in [18.0, 26]
            {
                for width in [120.0, 240, 480]
                {
                    let lines = try LayoutPlannedCodeFixture.lines([
                        LayoutFixture.direct(text)
                    ], width: width, size: size)
                    var sourceOffset = 0
                    for line in lines
                    {
                        #expect(line.frame.maxX <= width)
                        #expect(line.frame.size.height > 0)
                        #expect(line.caretStops.count == line.text.count + 1)
                        for caret in line.caretStops
                        {
                            #expect(caret.position.x >= -0.01)
                            #expect(caret.position.x <= width + 0.01)
                            #expect(caret.position.y == line.baseline.y)
                            #expect(caret.sourcePoint == .block(
                                blockID: LayoutFixture.blockID(0),
                                utf16Offset: sourceOffset + caret.utf16Offset
                            ))
                        }
                        sourceOffset += line.text.utf16.count
                    }
                    #expect(Array(lines.map(\.text).joined().utf16)
                        == Array(text.utf16))
                }
            }
        }
    }

    @MainActor
    @Test("translation moves glyphs and carets without changing code source")
    func translation() throws
    {
        let runs = [LayoutFixture.direct("let value = "),
                    try LayoutFixture.scoped("\"مرحبا e\u{301}\""),
                    LayoutFixture.direct(" + value.next", traits: [.strong])]
        let lines = try LayoutPlannedCodeFixture.lines(runs, width: 120)
        let shifted = try LayoutPlannedCodeFixture.lines(
            runs, width: 120, x: 37, y: 19
        )
        let expected = try lines.map
        {
            try NativeTextKit2Layout().translated($0, dx: 37, dy: 19)
        }
        #expect(shifted == expected)
        #expect(lines.flatMap(\.sourceSlices).map(\.text).joined()
            == runs.map(\.text).joined())
    }
}
