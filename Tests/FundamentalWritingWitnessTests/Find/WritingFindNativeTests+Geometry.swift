import AppKit
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingFindNativeTests
{
    @Test("Find controls fit and source matches remain visible",
          arguments: [360.0, 540.0, 820.0, 1150.0])
    func geometry(width: Double) throws
    {
        let source = Array(repeating: "A paragraph of writing.", count: 90)
            .joined(separator: "\n") + "\nNeedle"
        let window = try WritingTestWindow(session: DocumentSession(
            state: WritingTestDocument(source).state
        ), size: NSSize(width: width, height: 500))
        defer { window.close() }
        let controller = window.controller
        controller.findAndReplace(nil)
        let finder = try #require(controller.finder)
        finder.bar.query.stringValue = "Needle"
        finder.nextMatch(nil)
        let expected = NSRange(location: source.utf16.count - 6, length: 6)
        #expect(window.view.selectedRange() == expected)
        controller.documentWindow.contentView?.layoutSubtreeIfNeeded()
        let bar = finder.bar
        for control in [bar.query, bar.count, bar.previous, bar.next, bar.done,
                        bar.replacement, bar.replace, bar.replaceAll]
        {
            let frame = bar.convert(control.bounds, from: control)
            #expect(frame.minX >= 0)
            #expect(frame.maxX <= bar.bounds.width + 1)
            #expect(frame.minY >= -1)
            #expect(frame.maxY <= bar.bounds.height + 1)
            #expect(frame.width > 0)
        }
        #expect(!controller.scrollView.hasHorizontalScroller)
        try WritingWindowGeometry.expectVisibleCaret(
            window, context: "Find visible"
        )
        let height = controller.scrollView.frame.height
        finder.close(nil)
        #expect(controller.scrollView.frame.height > height)
        #expect(controller.documentWindow.firstResponder === window.view)
        #expect(window.view.selectedRange() == expected)
        try WritingWindowGeometry.expectVisibleCaret(
            window, context: "Find dismissed"
        )
    }
}
