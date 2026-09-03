import AppKit

@MainActor
package final class MacReaderWindowController:
    NSWindowController,
    NSWindowDelegate
{
    package let readerView: MacReaderView
    package let scrollView: NSScrollView

    package init?(
        contentSize: NSSize,
        screen: NSScreen,
        appearance: NSAppearance
    )
    {
        let contentRect = NSRect(origin: .zero, size: contentSize)
        let window = NSWindow(
            contentRect: contentRect,
            styleMask: [
                .titled,
                .closable,
                .miniaturizable,
                .resizable
            ],
            backing: .buffered,
            defer: false,
            screen: screen
        )
        guard let model = MacReaderModel(
            viewportWidth: contentSize.width,
            viewportHeight: contentSize.height,
            screen: screen,
            appearance: appearance
        )
        else
        {
            return nil
        }
        let scroll = NSScrollView(frame: contentRect)
        scroll.hasVerticalScroller = true
        scroll.hasHorizontalScroller = false
        scroll.autohidesScrollers = true
        scroll.borderType = .noBorder
        scroll.drawsBackground = false
        scroll.autoresizingMask = [.width, .height]
        let height = max(contentSize.height, model.documentHeight)
        let reader = MacReaderView(
            frame: NSRect(
                x: 0,
                y: 0,
                width: contentSize.width,
                height: height
            ),
            model: model
        )
        scroll.documentView = reader
        window.contentView = scroll
        window.title = "Fundamental"
        window.minSize = NSSize(width: 480, height: 360)
        readerView = reader
        scrollView = scroll
        super.init(window: window)
        window.delegate = self
        scroll.contentView.postsBoundsChangedNotifications = true
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(scrolled),
            name: NSView.boundsDidChangeNotification,
            object: scroll.contentView
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder)
    {
        fatalError()
    }

    package override func showWindow(_ sender: Any?)
    {
        super.showWindow(sender)
        synchronize()
    }

    package func windowDidResize(
        _ notification: Notification
    )
    {
        synchronize()
    }

    package func windowDidChangeBackingProperties(
        _ notification: Notification
    )
    {
        synchronize()
    }

    package func windowDidChangeScreen(
        _ notification: Notification
    )
    {
        synchronize()
    }

    package func windowDidMove(
        _ notification: Notification
    )
    {
        readerView.refreshAccessibilityGeometry()
    }

    @objc
    private func scrolled(_ notification: Notification)
    {
        synchronize()
    }

    package func synchronize()
    {
        _ = readerView.synchronizeFromScrollView()
    }
}
