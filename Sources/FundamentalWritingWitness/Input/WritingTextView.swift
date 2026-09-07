import AppKit

@MainActor
final class WritingTextView: NSTextView
{
    var terminalAttributes: [NSAttributedString.Key: Any] = [:]
    var hasListMarkers = false
    weak var listOverlay: WritingListOverlay?

    override func draw(_ dirtyRect: NSRect)
    {
        super.draw(dirtyRect)
        listOverlay?.needsDisplay = true
    }

    override func setFrameSize(_ newSize: NSSize)
    {
        let inset = max(24, (newSize.width -
            WritingSurfacePolicy.readableMeasure) / 2)
        let changesInset = textContainerInset.width != inset
        let tracksWidth = textContainer?.widthTracksTextView ?? false
        if changesInset
        {
            textContainer?.widthTracksTextView = false
        }
        super.setFrameSize(newSize)
        if changesInset
        {
            textContainerInset = NSSize(width: inset, height: 32)
            textContainer?.widthTracksTextView = tracksWidth
        }
        listOverlay?.frame = frame
    }
}
