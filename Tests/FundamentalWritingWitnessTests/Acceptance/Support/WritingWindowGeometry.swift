import AppKit
import Testing

@testable import FundamentalWritingWitness

@MainActor
struct WritingWindowGeometry
{
    static func expect(_ window: WritingTestWindow, width: CGFloat) throws
    {
        let native = window.controller.documentWindow
        let clip = window.controller.scrollView.contentView
        let container = try #require(window.view.textContainer)
        #expect(native.isVisible)
        #expect(window.view.window === native)
        #expect(window.view.frame.width == clip.bounds.width)
        #expect(abs(clip.bounds.width - width) < 1)
        #expect(window.view.textContainerInset.width ==
            max(24, (clip.bounds.width - 720) / 2))
        #expect(window.view.textContainerInset.height == 32)
        #expect(container.widthTracksTextView)
        #expect(container.lineFragmentPadding == 0)
        #expect(abs(container.size.width - 720) < 1)
        #expect(window.view.textLayoutManager != nil)
        #expect(window.view.font?.pointSize == 20)
        #expect(native.standardWindowButton(.closeButton) != nil)
        #expect(native.standardWindowButton(.miniaturizeButton) != nil)
        #expect(native.standardWindowButton(.zoomButton) != nil)
    }

    static func expectVisibleCaret(_ window: WritingTestWindow) throws
    {
        _ = try WritingWindowCapture.capture(window)
        let native = window.controller.documentWindow
        let visible = native.convertToScreen(window.view.convert(
            window.view.visibleRect, to: nil
        ))
        let rectangle = window.view.firstRect(
            forCharacterRange: window.view.selectedRange(), actualRange: nil
        )
        #expect(rectangle.height > 0)
        #expect(rectangle.minY >= visible.minY - 1)
        #expect(rectangle.maxY <= visible.maxY + 1)
    }
}
