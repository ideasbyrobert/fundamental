@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import CoreText
import Testing

@MainActor
struct SpacingOriginTests
{
    @Test func fractionalOriginsRetainNativeColorGlyphPlacement() throws
    {
        let origins = [
            CGPoint(x: 32, y: 48), CGPoint(x: 32.25, y: 48.5),
            CGPoint(x: 37.5, y: 52.25)
        ]
        for size in [18.0, 36]
        {
            let line = try SpacingFixture.text("👩‍💻 a", size: size)
            let native = try #require(line.plan.shaped.measurement.native)
            for (index, origin) in origins.enumerated()
            {
                for scale in [1.0, 2]
                {
                    let actual = try SpacingRaster(
                        width: line.advance + 80, height: 144, scale: scale
                    )
                    {
                        line.draw(
                            in: $0, origin: origin,
                            ink: CGColor(gray: 0, alpha: 1)
                        )
                    }
                    let reference = try SpacingRaster(
                        width: line.advance + 80, height: 144, scale: scale
                    )
                    {
                        $0.textMatrix = .identity
                        $0.textPosition = origin
                        CTLineDraw(native, $0)
                    }
                    let name = "origin-\(Int(size))-\(index)-\(Int(scale))"
                    try SpacingDifference.record(name, actual, reference)
                    #expect(actual.bytes == reference.bytes, "\(name)")
                    SpacingAssertions.unclipped(actual)
                    try SpacingEvidence.write(name, line: line, raster: actual)
                }
            }
        }
    }
}
