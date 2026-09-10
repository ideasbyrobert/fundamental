import AppKit

extension WritingNativeBridge
{
    func textView(
        _ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int
    ) -> Bool
    {
        true
    }

    func textView(
        _ view: NSTextView, menu: NSMenu, for event: NSEvent, at charIndex: Int
    ) -> NSMenu?
    {
        WritingContextMenu.make(in: projection)
    }
}
