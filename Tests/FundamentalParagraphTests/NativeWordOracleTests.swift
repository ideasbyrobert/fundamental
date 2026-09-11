import Foundation
import FundamentalNativeParagraph
import NaturalLanguage
import Testing

@Suite("Product words match independent native enumeration")
struct NativeWordOracleTests
{
    static let texts = [
        "extraordinary! English and русский текст.",
        "👩‍💻 cafe\u{301} раи\u{306}он 👨‍👩‍👧‍👦",
        "alpha\u{A0}beta no\u{2060}break a\u{200D}b",
        "first\r\nsecond\u{2028}third\u{2029}fourth",
        "person@example.com 12.34 https://example.com",
        ""
    ]

    @Test(arguments: texts, [NativeWordLanguage.english, .russian])
    func nativeRangesFlagsAndSourceAgree(
        _ text: String, _ language: NativeWordLanguage
    ) throws
    {
        let source = try WordFixture.source([WordFixture.run(text)])
        let actual = try NativeParagraphWords(
            source: source, language: language
        )
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        tokenizer.setLanguage(NLLanguage(rawValue: language.rawValue))
        var ranges: [Range<Int>] = []
        var flags: [UInt64] = []
        tokenizer.enumerateTokens(in: text.startIndex..<text.endIndex)
        {
            range, attributes in
            let lower = text.utf16.distance(
                from: text.utf16.startIndex, to: range.lowerBound
            )
            let upper = text.utf16.distance(
                from: text.utf16.startIndex, to: range.upperBound
            )
            ranges.append(lower..<upper)
            flags.append(UInt64(attributes.rawValue))
            return true
        }
        #expect(actual.observations.map(\.resolution.range) == ranges)
        #expect(actual.observations.map(\.flags) == flags)
        #expect(actual.observations.map(\.resolution)
            == ranges.map(source.resolve))
        #expect(actual.returnedUTF16 == Array(text.utf16))
    }
}
