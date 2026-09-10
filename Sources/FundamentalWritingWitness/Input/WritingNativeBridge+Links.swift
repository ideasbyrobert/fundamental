import AppKit

extension WritingNativeBridge
{
    func textView(
        _ textView: NSTextView, clickedOnLink link: Any, at charIndex: Int
    ) -> Bool
    {
        true
    }
}
