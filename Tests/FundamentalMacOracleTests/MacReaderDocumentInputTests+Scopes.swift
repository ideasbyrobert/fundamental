import AppKit
import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacReaderDocumentInputTests
{
    @Test("native copying preserves scoped Unicode source slices")
    func scopedSource() throws
    {
        let source = try MacReaderDocumentFixture.source([
            MacReaderDocumentFixture.scopedParagraph()
        ])
        let controller = try MacReaderDocumentFixture.window(source)
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        controller.synchronize()
        let block = try #require(source.document.content.blocks.first)
        let model = controller.readerView.model
        try MacReaderDocumentFixture.expectSource(source, in: model)
        let line = try #require(model.snapshot.presentedDocument.residents.all
            .compactMap { MacReaderDocumentFixture.line($0.content) }.first)
        let expected: [PresentationRunScope] = [
            .direct, .link("https://example.invalid/e\u{301}"),
            .language("ru-RU"),
            .linkAndLanguage(link: "https://example.invalid/e\u{301}",
                             language: "ru-RU")
        ]
        #expect(line.sourceSlices.map(\.scope) == expected)
        #expect(line.sourceSlices.map(\.text)
            == ["Direct ", "Link e\u{301} ", "Язык ", "Both 👩🏽‍💻"])
        let selection = try MacReaderDocumentFixture.copy(
            blockID: block.blockID.value, from: controller
        )
        #expect(selection.sourceSlices == line.sourceSlices)
        #expect(selection.text.utf16.elementsEqual(
            try MacReaderDocumentFixture.runs(block.block)
                .map(\.text).joined().utf16
        ))
        try MacReaderDocumentFixture.capture(controller, name: "scoped-copy")
    }
}
