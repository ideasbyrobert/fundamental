import AppKit
import CoreText
import Testing

@testable import FundamentalNativeWrapping

@MainActor
@Suite("Contextual native wrapping measurements")
struct NativeWrappingTextTests
{
    @Test("copying isolates text and supported attribute replacement")
    func snapshot() throws
    {
        let paragraph = NSMutableParagraphStyle()
        paragraph.headIndent = 23
        let input = NSMutableAttributedString(
            string: "e\u{301}\r\nРусские слова",
            attributes: [.font: NativeWrappingFixture.font,
                         .paragraphStyle: paragraph.copy()]
        )
        let measured = try #require(NativeWrappingText(input))
        let original = Array(input.string.utf16)
        paragraph.headIndent = 90
        input.addAttribute(.paragraphStyle, value: paragraph.copy(),
                           range: NSRange(location: 0, length: input.length))
        input.mutableString.setString("replacement")
        #expect(measured.source.utf16 == original)
        #expect(Array(measured.attributed.string.utf16) == original)
        let copied = try #require(measured.attributed.attribute(
            .paragraphStyle, at: 0, effectiveRange: nil
        ) as? NSParagraphStyle)
        #expect(copied.headIndent == 23)
    }

    @Test("full whitespace advance remains measurable")
    func whitespace() throws
    {
        let text = try #require(NativeWrappingText(NativeWrappingFixture.text(
            String(repeating: " ", count: 40)
        )))
        let line = try #require(text.line(in: 0 ..< 40, inlineOffset: 0))
        #expect(line.native != nil)
        #expect(line.advance > 120)
        #expect(abs(line.advance - line.trailingWhitespace) < 0.001)
        #expect(abs(line.advance - NativeWrappingFixture.indentation * 10)
            < 0.001)
    }

    @Test("a tab retains its source range and actual inline offset")
    func contextualTab() throws
    {
        let attributed = NativeWrappingFixture.text("\talpha\tbeta\tgamma\t")
        let text = try #require(NativeWrappingText(attributed))
        let offset = NativeWrappingFixture.indentation
        let line = try #require(text.line(
            in: 10 ..< 12, inlineOffset: offset
        ))
        let isolated = CTLineCreateWithAttributedString(
            attributed.attributedSubstring(from: NSRange(
                location: 10, length: 2
            ))
        )
        let advance = CTLineGetTypographicBounds(isolated, nil, nil, nil)
        #expect(abs(line.advance - advance) > 0.5)
        let range = CTLineGetStringRange(try #require(line.native))
        #expect(range.location == 0 && range.length == 2)
        #expect(range.location + line.range.lowerBound == 10)
        #expect(line.attributed.string == "a\t")
        #expect(line.range == 10 ..< 12 && line.inlineOffset == offset)
    }
}
