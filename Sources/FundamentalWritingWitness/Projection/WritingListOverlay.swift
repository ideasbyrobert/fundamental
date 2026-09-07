import AppKit

@MainActor
final class WritingListOverlay: NSView
{
    weak var textView: WritingTextView?

    override var isFlipped: Bool
    {
        true
    }

    override func hitTest(_ point: NSPoint) -> NSView?
    {
        nil
    }

    override func draw(_ dirtyRect: NSRect)
    {
        guard let view = textView,
              let context = NSGraphicsContext.current?.cgContext
        else
        {
            return
        }
        for marker in view.listMarkers(in: dirtyRect)
        {
            marker.draw(in: context)
        }
    }
}
