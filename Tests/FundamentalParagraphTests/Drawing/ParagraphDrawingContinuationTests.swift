import CoreText
import FundamentalNativeParagraph
import Testing

@MainActor
struct ParagraphDrawingContinuationTests
{
    @Test func followingNativeTextKeepsItsCallerPositionAndAppearance() throws
    {
        let blank = try SpacingFixture.text("")
        let following = try SpacingFixture.text("Following text")
        let native = try #require(following.plan.shaped.measurement.native)
        let reference = try raster(native) { _ in }
        let actual = try raster(native)
        {
            blank.draw(
                in: $0, origin: SpacingFixture.origin,
                ink: CGColor(red: 1, green: 0, blue: 0, alpha: 1)
            )
        }
        try SpacingDifference.record("following-native-text", actual, reference)
        #expect(actual.bytes == reference.bytes)
        SpacingAssertions.unclipped(reference)
        try PatternEvidence.write(
            "following", group: "drawing-context-controls", record: [
                "samePixels": actual.bytes == reference.bytes,
                "actual": SpacingEvidence.describe(actual),
                "reference": SpacingEvidence.describe(reference)
            ]
        )
    }

    private func raster(
        _ line: CTLine, before: (CGContext) throws -> Void
    ) throws -> SpacingRaster
    {
        try SpacingRaster(width: 240, height: 144, scale: 2)
        {
            context in
            context.textMatrix = CGAffineTransform(
                a: 1.125, b: 0.125, c: 0, d: 1, tx: 0, ty: 0
            )
            context.textPosition = CGPoint(x: 32.25, y: 48.5)
            context.setFillColor(
                CGColor(red: 0.2, green: 0.3, blue: 0.7, alpha: 1)
            )
            try before(context)
            CTLineDraw(line, context)
        }
    }
}
