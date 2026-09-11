import CoreText
import Testing

@testable import FundamentalNativeWrapping
@testable import FundamentalWrapping

@Suite("Code wrapping exact source corpus")
struct NativeCodeWrappingCorpusTests
{
    @MainActor
    @Test("width and font reflow retain Unicode, hard lines and full advances")
    func reflow() throws
    {
        let corpus = [
            "", String(repeating: " ", count: 40),
            "alpha" + String(repeating: " ", count: 40),
            "\talpha\tbeta\tgamma\t", "\u{85}\u{b}\u{c}\u{2028}\u{2029}",
            "A\nB\rC\r\nD\u{85}E\u{b}F\u{c}G\u{2028}H\u{2029}",
            "👩🏽‍💻 e\u{301} é 🇦🇲\r\n", "let שלום = \"مرحبا мир\"",
            "try container.encode(traits.sorted { $0.rawValue < "
                + "$1.rawValue }, forKey: .traits)",
            "// a comment with a long /alpha/beta/gamma/path/file.swift"
        ]
        for text in corpus
        {
            for size in [18.0, 26]
            {
                for width in [120.0, 240, 480]
                {
                    let result = try NativeCodeFixture.wrap(
                        text, width: width, size: size
                    )
                    #expect(Array(result.lines.map(\.attributed.string)
                        .joined().utf16) == Array(text.utf16))
                    #expect(result.plan.lines.count == result.lines.count)
                    for (choice, line) in zip(result.plan.lines, result.lines)
                    {
                        #expect(choice.range == line.range)
                        let advance = line.native.map
                        {
                            CTLineGetTypographicBounds($0, nil, nil, nil)
                        } ?? 0
                        #expect(advance + choice.indentation <= width)
                        #expect(result.plan.source.isBoundary(
                            choice.range.upperBound
                        ))
                    }
                    let hard = result.plan.lines.filter
                    {
                        if case .hard = $0.breakKind
                        {
                            return true
                        }
                        return false
                    }
                    #expect(hard.count == WrappingSource(text).lines.count - 1)
                }
            }
        }
    }
}
