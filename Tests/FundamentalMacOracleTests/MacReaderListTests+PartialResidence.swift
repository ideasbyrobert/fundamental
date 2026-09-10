import AppKit
import Testing

@testable import FundamentalMacOracle

extension MacReaderListTests
{
    @Test("a scrolled item keeps its index without repeating an absent marker")
    func partialResidence() throws
    {
        let text = (0 ..< 160).map { "Source line \($0)" }
            .joined(separator: "\n")
        let source = try MacReaderDocumentFixture.source(
            (0 ..< 9).map
            {
                MacReaderListFixture.block(.numbered, "Item \($0)")
            }
                + [MacReaderListFixture.block(.numbered, text)]
        )
        let controller = try MacReaderDocumentFixture.window(
            source, width: 600, height: 400
        )
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        controller.synchronize()
        let view = controller.readerView
        controller.scrollView.contentView.scroll(to: NSPoint(
            x: 0, y: view.model.documentHeight - 500
        ))
        controller.synchronize()
        let id = try #require(source.document.content.blocks.last).blockID
        let residents = view.model.snapshot.presentedDocument.residents.all
            .filter { $0.residentID.blockID == id.value }
        let first = try #require(residents.first)
        let last = try #require(residents.last)
        #expect(first.residentID.fragmentOrdinal > 0)
        #expect(residents.allSatisfy { $0.content.listMarker == nil })
        let firstCaret = try #require(first.content.textLine?.caretSites.first)
        let lastCaret = try #require(last.content.textLine?.caretSites.last)
        let start = firstCaret.sourcePoint.utf16Offset
        let end = lastCaret.sourcePoint.utf16Offset
        let expected = (text as NSString).substring(with: NSRange(
            location: start, length: end - start
        ))
        let groups = try MacReaderListFixture.groups(view)
        let group = try #require(groups.last)
        try MacReaderListFixture.expectGroup(
            group, text: expected, index: 9, label: "10.", marker: false
        )
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
    }
}
