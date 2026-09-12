import AppKit

@MainActor
final class WritingWindowContent: NSView
{
    let scroll: NSScrollView
    var findBar: WritingFindBar?

    override var isFlipped: Bool { true }

    init(scroll: NSScrollView)
    {
        self.scroll = scroll
        super.init(frame: scroll.frame)
        autoresizingMask = [.width, .height]
        scroll.autoresizingMask = []
        addSubview(scroll)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder)
    {
        return nil
    }

    func show(_ bar: WritingFindBar)
    {
        if findBar !== bar
        {
            findBar?.removeFromSuperview()
            findBar = bar
            addSubview(bar)
        }
        needsLayout = true
        layoutSubtreeIfNeeded()
    }

    override func setFrameSize(_ newSize: NSSize)
    {
        super.setFrameSize(newSize)
        needsLayout = true
    }

    override func layout()
    {
        let height = findBar.flatMap
        {
            $0.isHidden ? nil : $0.preferredHeight
        } ?? 0
        findBar?.frame = NSRect(x: 0, y: 0,
                               width: bounds.width, height: height)
        scroll.frame = NSRect(x: 0, y: height, width: bounds.width,
                              height: max(0, bounds.height - height))
        super.layout()
    }
}
