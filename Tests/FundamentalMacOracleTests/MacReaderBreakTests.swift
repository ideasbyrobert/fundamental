import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle
@testable import FundamentalPresentation

@MainActor
@Suite("Reader line-break selection", .serialized)
struct MacReaderBreakTests
{
    @Test("a native mouse drag selects and copies a line break",
          arguments: MacReaderBreakKind.allCases)
    func mouseCopy(kind: MacReaderBreakKind) throws
    {
        let source = try MacReaderDocumentFixture.source([kind.block("\n")])
        let retained = source
        let controller = try MacReaderDocumentFixture.window(
            source, width: 360, height: 240
        )
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        controller.synchronize()
        let model = controller.readerView.model
        let document = model.snapshot.presentedDocument
        let residents = document.residents.all
        try #require(residents.count == 2)
        let firstLine = try #require(residents.first?.content.textLine)
        let lastLine = try #require(residents.last?.content.textLine)
        let first = firstLine.firstCaretSite
        let last = try #require(lastLine.caretSites.last)
        #expect(firstLine.text == "\n")
        #expect(lastLine.text.isEmpty)
        #expect(first.sourcePoint.utf16Offset == 0)
        #expect(last.sourcePoint.utf16Offset == 1)
        #expect(last.position.y > first.position.y)
        #expect(model.nearestPosition(to: first.position)?.sourcePoint
            == first.sourcePoint)
        #expect(model.nearestPosition(to: last.position)?.sourcePoint
            == last.sourcePoint)
        let block = source.document.content.blocks[0]
        let selected = try MacReaderDocumentFixture.copy(
            blockID: block.blockID.value, from: controller
        )
        #expect(selected.text.utf16.elementsEqual("\n".utf16))
        #expect(selected.fragments.count == 1)
        #expect(selected.firstFragment.logicalBounds.size.width > 0)
        #expect(selected.firstFragment.range == 0 ..< 1)
        try MacReaderDocumentFixture.capture(
            controller, name: "break-lf-\(kind)"
        )
        #expect(source == retained)
    }
}
