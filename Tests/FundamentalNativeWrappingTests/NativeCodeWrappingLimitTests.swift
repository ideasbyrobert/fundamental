import AppKit
import Testing

@testable import FundamentalNativeWrapping

@Suite("Code wrapping limits and work")
struct NativeCodeWrappingLimitTests
{
    @MainActor
    @Test("invalid and impossible widths are explicit refusals")
    func refusal() throws
    {
        let font = NativeCodeFixture.font()
        let input = NSAttributedString(string: "👩🏽‍💻", attributes: [.font: font])
        for width in [0.0, -1, .nan, .infinity, 0.1]
        {
            #expect(NativeCodeWrapping.make(input, font: font, width: width)
                == nil)
        }
    }

    @MainActor
    @Test("long tokens and many hard lines require bounded fragment work")
    func work() throws
    {
        for text in [String(repeating: "identifier", count: 1_000),
                     String(repeating: "    call(alpha, beta)\n", count: 500)]
        {
            let result = try NativeCodeFixture.wrap(text, width: 120)
            let repeated = try NativeCodeFixture.wrap(text, width: 120)
            #expect(result.plan == repeated.plan)
            #expect(result.lines.map(\.attributed.string).joined() == text)
            #expect(result.measuredFragments < text.count * 6)
            #expect(result.measuredFragments == repeated.measuredFragments)
        }
    }
}
