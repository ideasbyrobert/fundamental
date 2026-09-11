import AppKit
import CoreText
import Testing

@MainActor
struct LayoutBaselineRaster
{
    let image: CGImage
    let data: Data

    init(
        _ fixture: LayoutBaselineFixture, scale: Double, native: Bool
    ) throws
    {
        let width = ceil(CTLineGetTypographicBounds(
            fixture.line, nil, nil, nil
        ) + fixture.baseline.x + 40)
        let height = 160.0
        let pixelsWide = Int(ceil(width * scale))
        let pixelsHigh = Int(height * scale)
        let space = try #require(CGColorSpace(name: CGColorSpace.sRGB))
        let context = try #require(CGContext(
            data: nil, width: pixelsWide, height: pixelsHigh,
            bitsPerComponent: 8, bytesPerRow: pixelsWide * 4, space: space,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                | CGBitmapInfo.byteOrder32Big.rawValue
        ))
        context.scaleBy(x: scale, y: scale)
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.setShouldAntialias(true)
        context.setShouldSmoothFonts(false)
        context.setFillColor(CGColor(gray: 0, alpha: 1))
        context.textMatrix = .identity
        if native
        {
            context.textPosition = CGPoint(
                x: fixture.baseline.x, y: height - fixture.baseline.y
            )
            CTLineDraw(fixture.line, context)
        }
        else
        {
            let rawRuns = CTLineGetGlyphRuns(fixture.line) as! [CTRun]
            context.textPosition = .zero
            for (index, run) in fixture.runs.enumerated()
            {
                let attributes = CTRunGetAttributes(rawRuns[index])
                    as NSDictionary
                let font = attributes[kCTFontAttributeName] as! CTFont
                let glyphs = run.glyphs.map { CGGlyph($0.identifier) }
                let positions = run.glyphs.map
                {
                    CGPoint(x: $0.position.x, y: height - $0.position.y)
                }
                CTFontDrawGlyphs(
                    font, glyphs, positions, glyphs.count, context
                )
            }
        }
        image = try #require(context.makeImage())
        data = try #require(image.dataProvider?.data) as Data
    }
}
