import AppKit

@MainActor
final class WritingTextView: NSTextView
{
    override func setFrameSize(_ newSize: NSSize)
    {
        super.setFrameSize(newSize)
        let inset = max(24, (newSize.width -
            WritingSurfacePolicy.readableMeasure) / 2)
        if textContainerInset.width != inset
        {
            textContainerInset = NSSize(width: inset, height: 32)
        }
    }
}
