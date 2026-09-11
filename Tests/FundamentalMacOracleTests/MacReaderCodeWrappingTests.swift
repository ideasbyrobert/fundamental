import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle
@testable import FundamentalPresentation

@MainActor
@Suite("Reader code wrapping interaction", .serialized)
struct MacReaderCodeWrappingTests
{
    @Test("the signing reference reflows and draws within the Reader measure")
    func signingReflow() throws
    {
        let text = MacReaderCodeReference.signing
        let source = try document(text)
        for width in [360.0, 600]
        {
            let controller = try MacReaderDocumentFixture.window(
                source, width: width, height: 1_000
            )
            let window = try #require(controller.window)
            defer { window.close() }
            controller.showWindow(nil)
            controller.synchronize()
            let model = controller.readerView.model
            let lines = model.snapshot.presentedDocument.residents.all
                .compactMap(\.content.textLine)
            #expect(lines.map(\.text).joined().utf16.elementsEqual(text.utf16))
            #expect(lines.count > text.split(separator: "\n").count)
            #expect(lines.allSatisfy
            {
                $0.lineBounds.maxX <= model.readableMeasure
            })
            #expect(lines.flatMap(\.caretSites).allSatisfy
            {
                $0.position.x >= 0 && $0.position.x <= model.readableMeasure
            })
            try MacReaderDocumentFixture.capture(
                controller, name: "code-signing-\(Int(width))"
            )
        }
    }

    @Test("native drag and Copy preserve wrapped whitespace and hard controls")
    func sourceCopy() throws
    {
        let text = "\tlet message = \"مرحبا мир 👩🏽‍💻 e\u{301}\""
            + String(repeating: " ", count: 40) + "\r\n\u{b}\u{c}next"
        let source = try document(text)
        let controller = try MacReaderDocumentFixture.window(
            source, width: 360, height: 680
        )
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        controller.synchronize()
        for reverse in [false, true]
        {
            let selected = try MacReaderDocumentFixture.copy(
                blockID: source.document.content.blocks[0].blockID.value,
                from: controller, reverse: reverse
            )
            #expect(selected.text.utf16.elementsEqual(text.utf16))
        }
        try MacReaderDocumentFixture.capture(
            controller, name: "code-whitespace-copy"
        )
    }

    private func document(_ text: String) throws -> DocumentSnapshot
    {
        try MacReaderDocumentFixture.source([
            .code(.plain(PlainSemanticCodeBlock(runs: [
                SemanticRun(text: text)
            ])))
        ])
    }
}
