package struct LayoutLine: Equatable, Sendable
{
    package let text: String
    package let frame: LayoutRectangle
    package let baseline: LayoutPoint
    package let sourceSlices: [LayoutSourceSlice]
    package let firstCaretStop: LayoutCaretStop
    package let remainingCaretStops: [LayoutCaretStop]
    package let defaultFont: LayoutFontIdentity
    package let glyphRuns: [LayoutGlyphRun]

    package var caretStops: [LayoutCaretStop]
    {
        [firstCaretStop] + remainingCaretStops
    }
}
