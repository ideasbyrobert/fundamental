import AppKit

extension MacReaderWindowController
{
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
    func scrolled(_ notification: Notification)
    {
        synchronize()
    }

    package func synchronize()
    {
        _ = readerView.synchronizeFromScrollView()
    }
}
