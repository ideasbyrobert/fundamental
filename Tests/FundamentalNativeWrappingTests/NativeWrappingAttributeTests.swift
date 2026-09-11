import AppKit
import Testing

@testable import FundamentalNativeWrapping

@MainActor
@Suite("Native wrapping attribute admission")
struct NativeWrappingAttributeTests
{
    @Test("a mutable paragraph value cannot enter retained shaping input")
    func mutableParagraph()
    {
        let paragraph = NSMutableParagraphStyle()
        paragraph.headIndent = 31
        let input = NSAttributedString(
            string: "input",
            attributes: [.font: NativeWrappingFixture.font,
                         .paragraphStyle: paragraph]
        )
        #expect(NativeWrappingText(input) == nil)
    }
}
