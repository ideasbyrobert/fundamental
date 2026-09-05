import AppKit
import FundamentalDocument

@MainActor
final class WritingWindowController: NSWindowController, NSWindowDelegate
{
    let documentWindow: NSWindow
    let textView: WritingTextView
    let scrollView: NSScrollView
    let bridge: WritingNativeBridge
    private let confirmDiscard: @MainActor () -> WritingCloseDecision
    private var discardApproved = false

    init?(
        session: DocumentSession,
        size: NSSize = NSSize(width: 820, height: 600),
        confirmDiscard: @escaping @MainActor () -> WritingCloseDecision =
            WritingClosePrompt.ask
    )
    {
        guard size.width.isFinite, size.height.isFinite,
              size.width >= 320, size.height >= 240,
              let bridge = WritingNativeBridge(session: session)
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
        guard bridge.project(in: view)
        else
        {
            return nil
        }
        scroll.documentView = view
        let window = NSWindow(
            contentRect: rectangle,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.title = "Fundamental Writing Witness — Unsaved"
        window.minSize = NSSize(width: 360, height: 280)
        window.contentView = scroll
        documentWindow = window
        textView = view
        scrollView = scroll
        self.bridge = bridge
        self.confirmDiscard = confirmDiscard
        super.init(window: window)
        window.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder)
    {
        return nil
    }

    override func showWindow(_ sender: Any?)
    {
        super.showWindow(sender)
        documentWindow.makeKeyAndOrderFront(sender)
        documentWindow.makeFirstResponder(textView)
    }

    func windowDidResize(_ notification: Notification)
    {
        let size = scrollView.contentSize
        textView.minSize = NSSize(width: 0, height: size.height)
        textView.setFrameSize(NSSize(
            width: size.width,
            height: max(size.height, textView.frame.height)
        ))
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool
    {
        sender === documentWindow && mayClose()
    }

    func windowWillClose(_ notification: Notification)
    {
        discardApproved = true
    }

    func mayClose() -> Bool
    {
        if discardApproved
        {
            return true
        }
        guard let current = WritingProjection(bridge.session.state)
        else
        {
            return false
        }
        if current.text.isEmpty
        {
            return true
        }
        switch confirmDiscard()
        {
        case .discard:
            discardApproved = true
            return true
        case .cancel:
            return false
        }
    }
}
