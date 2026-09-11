@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import AppKit
import CoreText
import Testing

@MainActor
struct SpacingNativeReferenceTests
{
    @Test func naturalGlyphPixelsMatchIndependentNativeLineDrawing() throws
    {
        let texts = ["AVATAR A T", "office fi a", "район раи\u{306}он",
                     "👩‍💻 a раи\u{306}он", " a b\tc ", "", "\u{AD}"]
        for (index, text) in texts.enumerated()
        {
            for scale in [1.0, 2]
            {
                let line = try SpacingFixture.text(text)
                try SpacingAssertions.geometry(line)
                let actual = try SpacingFixture.raster(line, scale: scale)
                let reference = try SpacingRaster(
                    width: max(line.advance, line.plan.metrics.advance) + 64,
                    height: 128, scale: scale
                )
                {
                    context in
                    context.textMatrix = .identity
                    context.textPosition = SpacingFixture.origin
                    if let native = line.plan.shaped.measurement.native
                    {
                        CTLineDraw(native, context)
                    }
                }
                try SpacingDifference.record(
                    "natural-\(index)-\(Int(scale))", actual, reference
                )
                #expect(actual.bytes == reference.bytes,
                        "Natural raster \(index) at scale \(scale)")
                SpacingAssertions.unclipped(actual, empty: index >= 5)
                try SpacingEvidence.write(
                    "natural-\(index)-\(Int(scale))", line: line, raster: actual
                )
            }
        }
    }

    @Test func spaceMovementMatchesNativeTrackingWhenTabsAreAbsent() throws
    {
        for amount in [-0.5, 2.0]
        {
            let line = try SpacingFixture.text("AVATAR a b", amount: amount)
            try SpacingAssertions.geometry(line)
            let actual = try SpacingFixture.raster(line)
            let attributed = NSMutableAttributedString(
                attributedString: line.plan.shaped.measurement.attributed
            )
            for gap in line.plan.metrics.gaps
            {
                attributed.addAttribute(
                    NSAttributedString.Key(kCTTrackingAttributeName as String),
                    value: amount,
                    range: NSRange(location: gap.index, length: 1)
                )
            }
            let native = CTLineCreateWithAttributedString(attributed)
            let reference = try SpacingRaster(
                width: max(line.advance, line.plan.metrics.advance) + 64,
                height: 128, scale: 2
            )
            {
                $0.textMatrix = .identity
                $0.textPosition = SpacingFixture.origin
                CTLineDraw(native, $0)
            }
            #expect(actual.bytes == reference.bytes)
            SpacingAssertions.unclipped(actual)
            try SpacingEvidence.write(
                "tracking-\(amount)", line: line, raster: actual
            )
        }
    }
}
