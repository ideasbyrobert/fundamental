import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingAcceptanceTests
{
    @Test(arguments: [NSAppearance.Name.aqua, .darkAqua],
          [360.0, 540, 820, 1_150])
    func formattingKeepsCaretVisibleAtSupportedWidths(
        appearance: NSAppearance.Name, width: Double
    ) throws
    {
        let texts = ["Formatting at every width", String(repeating:
            "A paragraph with words that wrap naturally. ", count: 24),
            "Caret witness e\u{301} 😀"]
        let window = try WritingTestWindow(
            styles: [.heading, .body, .body], texts: texts
        )
        defer
        {
            window.close()
        }
        let native = window.controller.documentWindow
        native.appearance = NSAppearance(named: appearance)
        window.select(window.view.string.utf16.count)
        window.view.scrollRangeToVisible(window.view.selectedRange())
        let before = window.storage
        native.setContentSize(NSSize(width: width, height: 600))
        #expect(abs(native.frame.width - width) < 1)
        #expect(window.storage == before)
        try expectFormattingCaret(window)
        try window.choose(.numbered)
        #expect(window.styles == [.heading, .body, .numbered])
        try expectFormattingCaret(window)
        try window.chooseNoList()
        #expect(window.styles == [.heading, .body, .body])
        try expectFormattingCaret(window)
        try window.expect(texts.joined(separator: "\n"), selection: NSRange(
            location: texts.joined(separator: "\n").utf16.count, length: 0
        ))
    }

    private func expectFormattingCaret(_ window: WritingTestWindow) throws
    {
        try WritingWindowGeometry.expectVisibleCaret(window)
        let native = window.controller.documentWindow
        let visible = native.convertToScreen(window.view.convert(
            window.view.visibleRect, to: nil
        ))
        let caret = window.view.firstRect(
            forCharacterRange: window.view.selectedRange(), actualRange: nil
        )
        #expect(native.firstResponder === window.view)
        #expect(caret.minX >= visible.minX)
        #expect(caret.maxX <= visible.maxX)
        #expect(!window.controller.scrollView.hasHorizontalScroller)
        #expect(window.view.bounds.width <= visible.width)
    }
}
