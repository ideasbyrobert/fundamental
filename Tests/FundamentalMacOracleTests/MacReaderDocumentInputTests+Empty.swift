import AppKit
import Testing

@testable import FundamentalMacOracle
@testable import FundamentalPresentation

extension MacReaderDocumentInputTests
{
    @Test("an empty supplied body is one native caret with no glyphs")
    func emptyBody() throws
    {
        let source = try MacReaderDocumentFixture.source([
            MacReaderDocumentFixture.paragraph("")
        ])
        let controller = try MacReaderDocumentFixture.window(source)
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        controller.synchronize()
        let model = controller.readerView.model
        let residents = model.snapshot.presentedDocument.residents.all
        try #require(residents.count == 1)
        let line = try #require(MacReaderDocumentFixture.line(
            residents[0].content
        ))
        #expect(line.text.isEmpty)
        #expect(line.sourceSlices.isEmpty)
        #expect(line.caretSites.count == 1)
        #expect(line.lineBounds.size.height > 0)
        #expect(model.snapshot.presentedDocument.marks.isEmpty)
        let site = line.firstCaretSite
        controller.readerView.mouseDown(
            with: try MacReaderInteractionTests.event(
                type: .leftMouseDown, site: site,
                view: controller.readerView, window: window
            )
        )
        guard case let .caret(_, caret) = model.snapshot
        else
        {
            Issue.record("The empty source caret was not published")
            return
        }
        #expect(caret.position.sourcePoint == .block(
            blockID: residents[0].residentID.blockID, utf16Offset: 0
        ))
        #expect(caret.logicalBounds.size.height == line.lineBounds.size.height)
        try MacReaderDocumentFixture.expectSource(source, in: model)
    }
}
