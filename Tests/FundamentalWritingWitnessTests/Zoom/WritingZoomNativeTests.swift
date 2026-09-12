import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

@MainActor
@Suite("Native writing zoom", .serialized)
struct WritingZoomNativeTests
{
    @Test("zoom preserves provisional text and its original transaction")
    func markedInput() throws
    {
        let window = try WritingTestWindow("AB")
        defer { window.close() }
        window.select(1, 0)
        let state = window.session.state
        window.mark("e\u{301}")
        let range = window.view.markedRange()
        let selection = window.view.selectedRange()
        #expect(window.controller.bridge.setZoom(WritingZoom(150),
                                                  in: window.view))
        #expect(window.view.hasMarkedText())
        #expect(window.view.markedRange() == range)
        #expect(window.view.selectedRange() == selection)
        #expect(window.session.state == state)
        #expect(!window.session.canUndo)
        window.commit("é")
        try window.expect("AéB", selection: NSRange(location: 2, length: 0))
        #expect(window.session.history.undo.count == 1)
        let font = try #require(window.view.textStorage?.attribute(.font,
            at: 1, effectiveRange: nil) as? NSFont)
        #expect(font.pointSize == 30)
        window.controller.updateWritingGeometry()
    }
}
