import AppKit

@MainActor
struct WritingWindowSurface
{
    let window: NSWindow
    let view: WritingTextView
    let scroll: NSScrollView

    init?(size: NSSize, bridge: WritingNativeBridge)
    {
        guard size.width.isFinite, size.height.isFinite,
              size.width >= 320, size.height >= 240
        else
        {
            return nil
        }
        let view = WritingTextView(usingTextLayoutManager: true)
        guard WritingTextConfiguration.apply(to: view)
        else
        {
            return nil
        }
        let rectangle = NSRect(origin: .zero, size: size)
        let scroll = NSScrollView(frame: rectangle)
        scroll.hasVerticalScroller = true
        scroll.hasHorizontalScroller = false
        scroll.autohidesScrollers = true
        scroll.borderType = .noBorder
        scroll.backgroundColor = .textBackgroundColor
        scroll.autoresizingMask = [.width, .height]
        view.frame = NSRect(origin: .zero, size: scroll.contentSize)
        view.minSize = NSSize(width: 0, height: scroll.contentSize.height)
        view.delegate = bridge
        scroll.documentView = view
        let overlay = WritingListOverlay(frame: view.frame)
        overlay.textView = view
        overlay.setAccessibilityElement(false)
        view.listOverlay = overlay
        scroll.contentView.addSubview(overlay, positioned: .above,
                                       relativeTo: view)
        let window = NSWindow(
            contentRect: rectangle,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 360, height: 280)
        window.contentView = scroll
        guard bridge.project(in: view)
        else
        {
            return nil
        }
        self.window = window
        self.view = view
        self.scroll = scroll
    }
}
