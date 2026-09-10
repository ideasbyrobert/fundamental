import AppKit
import FundamentalPresentation

@MainActor
enum MacAccessibilityTree
{
    static func elements(
        document: PresentedDocument,
        view: NSView,
        horizontalInset: Double
    ) -> [MacAccessibilityElement]
    {
        elements(
            residents: document.residents.all,
            view: view,
            horizontalInset: horizontalInset
        )
    }
}
