import AppKit
import FundamentalPresentation

extension MacAccessibilityTree
{
    static func screenFrame(
        _ resident: PresentedResident,
        view: NSView,
        horizontalInset: Double
    ) -> NSRect
    {
        let local = NSRect(
            x: resident.frame.minX + horizontalInset,
            y: resident.frame.minY,
            width: resident.frame.size.width,
            height: resident.frame.size.height
        )
        let windowFrame = view.convert(local, to: nil)
        return view.window?.convertToScreen(windowFrame)
            ?? windowFrame
    }
}
