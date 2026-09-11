import CoreGraphics

package struct SpacedNativeGlyph: Sendable
{
    package let original: MappedNativeGlyph<HyphenatedGlyphSource>
    package let position: CGPoint
    package let advance: CGSize

    init(
        _ original: MappedNativeGlyph<HyphenatedGlyphSource>,
        adjustments: SpacingAdjustments, gaps: inout Set<Int>
    ) throws
    {
        let before = adjustments.count(before: original.displayRange.lowerBound)
        let after = adjustments.count(before: original.displayRange.upperBound)
        let isGap = adjustments.isGap(original.stringIndex)
        guard after == before || (isGap && original.displayRange.count == 1)
        else
        {
            throw NativeSpacingFailure.ambiguousGap
        }
        if isGap, !gaps.insert(original.stringIndex).inserted
        {
            throw NativeSpacingFailure.ambiguousGap
        }
        self.original = original
        position = CGPoint(
            x: original.position.x + Double(before) * adjustments.amount,
            y: original.position.y
        )
        advance = CGSize(
            width: original.advance.width + (isGap ? adjustments.amount : 0),
            height: original.advance.height
        )
        guard position.x.isFinite, advance.width.isFinite,
              !isGap || advance.width > 0
        else
        {
            throw NativeSpacingFailure.invalidPlan
        }
    }
}
