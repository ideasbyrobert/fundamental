import AppKit
import FundamentalPresentation

extension MacAccessibilityTree
{
    static func element(
        _ semantics: MacAccessibilitySemantics,
        resident: PresentedResident,
        view: NSView,
        horizontalInset: Double,
        parent: AnyObject? = nil
    ) -> MacAccessibilityElement
    {
        element(
            semantics,
            frame: screenFrame(
                resident,
                view: view,
                horizontalInset: horizontalInset
            ),
            parent: parent ?? view
        )
    }

    static func element(
        _ semantics: MacAccessibilitySemantics,
        frame: NSRect,
        parent: AnyObject
    ) -> MacAccessibilityElement
    {
        return MacAccessibilityElement(
            semantics: semantics,
            frame: frame,
            parent: parent
        )
    }
}
