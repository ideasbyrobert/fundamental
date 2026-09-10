import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacReaderBreakTests
{
    @Test("native copy preserves hard breaks between empty neighbors",
          arguments: MacReaderBreakKind.allCases, [240.0, 540.0])
    func sourceBoundaries(kind: MacReaderBreakKind, width: Double) throws
    {
        let texts = [
            "\r", "\r\n", "\u{2028}", "\u{2029}", "\n\n", "A\n",
            "A\r\nB", "\nA\n", "e\u{301} 👩🏽‍💻\n",
            String(repeating: "Alpha beta ", count: 12) + "\n"
        ]
        for (index, text) in texts.enumerated()
        {
            let source = try MacReaderDocumentFixture.source([
                kind.block(""), kind.block(text), kind.block("")
            ])
            let retained = source
            let controller = try MacReaderDocumentFixture.window(
                source, width: width, height: 760
            )
            let window = try #require(controller.window)
            defer { window.close() }
            controller.showWindow(nil)
            controller.synchronize()
            let identifier = source.document.content.blocks[1].blockID.value
            let forward = try MacReaderDocumentFixture.copy(
                blockID: identifier, from: controller
            )
            let reverse = try MacReaderDocumentFixture.copy(
                blockID: identifier, from: controller, reverse: true
            )
            #expect(forward.text.utf16.elementsEqual(text.utf16))
            #expect(reverse.text.utf16.elementsEqual(text.utf16))
            #expect(forward.fragments == reverse.fragments)
            #expect(forward.anchor == reverse.focus)
            #expect(forward.focus == reverse.anchor)
            #expect(forward.sourceSlices.allSatisfy
            {
                $0.source.domain == .block(identifier)
            })
            #expect(forward.fragments.allSatisfy
            {
                $0.logicalBounds.size.width > 0
            })
            #expect(source == retained)
            if index == 2 || index == texts.count - 1
            {
                try MacReaderDocumentFixture.capture(
                    controller, name: "break-\(index)-\(kind)-\(Int(width))"
                )
            }
        }
    }
}
