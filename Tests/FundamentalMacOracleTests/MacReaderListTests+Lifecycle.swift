import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalMacOracle

extension MacReaderListTests
{
    @Test("lists survive native scroll resize and appearance changes",
          arguments: SemanticListKind.allCases)
    func nativeLifecycle(kind: SemanticListKind) throws
    {
        let source = try MacReaderDocumentFixture.source((0 ..< 300).map
        {
            MacReaderListFixture.block(kind, "Value \($0) e\u{301} 😀")
        })
        let retained = source
        let controller = try MacReaderDocumentFixture.window(
            source, width: 600, height: 400
        )
        let window = try #require(controller.window)
        defer { window.close() }
        controller.showWindow(nil)
        controller.synchronize()
        let model = controller.readerView.model
        let clip = controller.scrollView.contentView
        let initial = model.layoutExecutionCount
        let before = model.snapshot.presentedDocument.residents.all
        clip.scroll(to: NSPoint(x: 0, y: model.documentHeight / 2))
        controller.synchronize()
        #expect(model.visibleOriginY > 0)
        #expect(model.layoutExecutionCount == initial)
        #expect(model.snapshot.presentedDocument.residents.all != before)
        try MacReaderDocumentFixture.expectSource(source, in: model)
        window.appearance = try MacOracleTestSurface.appearance(.darkAqua)
        controller.synchronize()
        #expect(model.layoutExecutionCount == initial)
        try MacReaderEnvironmentTestSupport.expectCurrent(controller)
        clip.scroll(to: NSPoint(x: 0, y: model.documentHeight))
        controller.synchronize()
        window.setContentSize(NSSize(width: 820, height: 400))
        controller.synchronize()
        #expect(model.layoutExecutionCount == initial + 1)
        #expect(model.visibleOriginY.bitPattern == clip.bounds.minY.bitPattern)
        #expect(!controller.scrollView.hasHorizontalScroller)
        try MacReaderDocumentFixture.expectSource(source, in: model)
        try MacAccessibilityGeometryTestSupport.expectSettled(controller)
        let last = try #require(source.document.content.blocks.last)
        #expect(model.snapshot.presentedDocument.residents.all.contains
        {
            $0.residentID.blockID == last.blockID.value
        })
        let selection = try MacReaderDocumentFixture.copy(
            blockID: last.blockID.value, from: controller
        )
        #expect(selection.text.utf16.elementsEqual(
            try MacReaderDocumentFixture.runs(last.block)
                .map(\.text).joined().utf16
        ))
        #expect(source == retained)
        try MacReaderDocumentFixture.capture(
            controller, name: "lists-scrolled-dark-\(kind)"
        )
    }
}
