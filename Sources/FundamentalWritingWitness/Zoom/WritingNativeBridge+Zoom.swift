import AppKit

extension WritingNativeBridge
{
    @discardableResult
    func setZoom(_ next: WritingZoom, in view: NSTextView) -> Bool
    {
        guard next != zoom
        else
        {
            return true
        }
        let visible = composition?.presentation ?? projection
        guard view.string.utf16.elementsEqual(visible.text.utf16),
              let presentation = WritingTextPresentation(visible, zoom: next)
        else
        {
            return false
        }
        projecting = true
        defer { projecting = false }
        presentation.restyle(in: view)
        zoom = next
        return true
    }
}
