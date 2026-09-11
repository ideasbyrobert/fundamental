import AppKit
import CoreText

@MainActor
package struct SpacedNativeRun
{
    package let original: MappedNativeRun<HyphenatedGlyphSource>
    package let font: CTFont
    package let baseline: Double
    package let glyphs: [SpacedNativeGlyph]
    package let decorations: [SpacingDecoration]

    init(
        native: CTRun, original: MappedNativeRun<HyphenatedGlyphSource>,
        plan: ParagraphPlannedLine, adjustments: SpacingAdjustments,
        gaps: inout Set<Int>
    ) throws
    {
        guard original.status & CTRunStatus.rightToLeft.rawValue == 0
        else
        {
            throw NativeSpacingFailure.unsupportedDirection
        }
        guard original.matrix == .identity
        else
        {
            throw NativeSpacingFailure.unsupportedMatrix
        }
        let attributes = CTRunGetAttributes(native) as NSDictionary
        guard let font = attributes[kCTFontAttributeName] as! CTFont?
        else
        {
            throw NativeSpacingFailure.missingFont
        }
        let style = plan.shaped.measurement.attributed.attributes(
            at: original.range.lowerBound, effectiveRange: nil
        )
        let baseline = (style[.baselineOffset] as? NSNumber)?.doubleValue ?? 0
        guard baseline.isFinite
        else
        {
            throw NativeSpacingFailure.invalidBaseline
        }
        let glyphs = try original.glyphs.map
        {
            try SpacedNativeGlyph($0, adjustments: adjustments, gaps: &gaps)
        }
        self.original = original
        self.font = font
        self.baseline = baseline
        self.glyphs = glyphs
        decorations = try SpacingDecoration.make(
            attributes: style, font: font, baseline: baseline, glyphs: glyphs,
            sources: plan.shaped.display.sources(in: original.range)
        )
    }
}
