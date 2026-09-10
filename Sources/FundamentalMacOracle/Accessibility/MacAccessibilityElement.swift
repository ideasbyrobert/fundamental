import AppKit

@MainActor
package final class MacAccessibilityElement: NSAccessibilityElement
{
    let semantics: MacAccessibilitySemantics
    let frameValue: NSRect
    nonisolated(unsafe) weak var parentValue: AnyObject?
    nonisolated(unsafe) var childValues: [MacAccessibilityElement]
    nonisolated(unsafe) var titleElementValues:
        [MacAccessibilityElement]

    init(
        semantics: MacAccessibilitySemantics,
        frame: NSRect,
        parent: AnyObject
    )
    {
        self.semantics = semantics
        frameValue = frame
        parentValue = parent
        childValues = []
        titleElementValues = []
        super.init()
    }
}
