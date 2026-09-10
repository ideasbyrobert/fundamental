import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacReaderDocumentInputTests
{
    @Test("all seven inline traits reach the supplied native document",
          arguments: [
            SemanticInlineTrait.strong, .emphasis, .underline,
            .strikethrough, .inlineCode, .superscript, .subscriptText
          ])
    func inlineTraits(trait: SemanticInlineTrait) throws
    {
        let text = "Native source"
        let source = try MacReaderDocumentFixture.source([
            MacReaderDocumentFixture.paragraph(text),
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: text, traits: [trait])
            ]))
        ])
        let controller = try MacReaderDocumentFixture.window(source)
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        controller.synchronize()
        let model = controller.readerView.model
        try MacReaderDocumentFixture.expectSource(source, in: model)
        let batches = model.snapshot.presentedDocument.marks.compactMap
        {
            mark -> PresentationGlyphBatch? in
            guard case let .glyphs(batch) = mark else { return nil }
            return batch
        }
        let plain = try #require(batches.first
        {
            $0.residentID.blockOrdinal == 0
        })
        let styled = try #require(batches.first
        {
            $0.residentID.blockOrdinal == 1
        })
        switch trait
        {
        case .strong, .emphasis, .inlineCode:
            #expect(styled.font != plain.font)
        case .superscript:
            #expect(styled.baselineOffset > plain.baselineOffset)
            #expect(styled.font == plain.font)
        case .subscriptText:
            #expect(styled.baselineOffset < plain.baselineOffset)
            #expect(styled.font == plain.font)
        case .underline, .strikethrough:
            let role: PresentationFillRole = trait == .underline
                ? .underline : .strikethrough
            #expect(model.snapshot.presentedDocument.marks.contains
            {
                guard case let .fill(fill) = $0 else { return false }
                return fill.role == role
                    && fill.residentID.blockOrdinal == 1
            })
        }
        let block = try #require(source.document.content.blocks.last)
        let selection = try MacReaderDocumentFixture.copy(
            blockID: block.blockID.value, from: controller
        )
        #expect(selection.text == text)
        try MacReaderDocumentFixture.capture(
            controller, name: "trait-\(trait.rawValue)"
        )
    }
}
