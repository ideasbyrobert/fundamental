import AppKit

extension WritingWindowController
{
    override func showWindow(_ sender: Any?)
    {
        super.showWindow(sender)
        documentWindow.makeKeyAndOrderFront(sender)
        documentWindow.makeFirstResponder(textView)
    }

    func windowDidResize(_ notification: Notification)
    {
        updateWritingGeometry()
    }

    func windowDidEndLiveResize(_ notification: Notification)
    {
        DispatchQueue.main.async
        {
            [weak self] in
            self?.updateWritingGeometry()
        }
    }

    private func updateWritingGeometry()
    {
        let size = scrollView.contentSize
        textView.minSize = NSSize(width: 0, height: size.height)
        textView.setFrameSize(NSSize(
            width: size.width,
            height: max(size.height, textView.frame.height)
        ))
        if let layout = textView.textLayoutManager,
           let content = layout.textContentManager
        {
            layout.ensureLayout(for: content.documentRange)
        }
        textView.scrollRangeToVisible(textView.selectedRange())
    }
}
