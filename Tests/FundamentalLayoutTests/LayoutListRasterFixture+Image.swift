import AppKit
import CoreText
import Testing

@testable import FundamentalLayout

extension LayoutListRasterFixture
{
    func image(width: Double, height: Double, scale: Double,
               draw: (CGContext) throws -> Void) throws -> CGImage
    {
        let pixelsWide = Int(ceil((width + 40) * scale))
        let pixelsHigh = Int(ceil((height + 40) * scale))
        let context = try #require(CGContext(
            data: nil, width: pixelsWide, height: pixelsHigh,
            bitsPerComponent: 8, bytesPerRow: pixelsWide * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: pixelsWide, height: pixelsHigh))
        context.translateBy(x: 0, y: CGFloat(pixelsHigh))
        context.scaleBy(x: scale, y: -scale)
        context.translateBy(x: 20.25, y: 20.5)
        context.setFillColor(CGColor(gray: 0, alpha: 1))
        context.setTextDrawingMode(.fill)
        try draw(context)
        return try #require(context.makeImage())
    }

    func actual(_ lines: [LayoutLine], in context: CGContext) throws
    {
        for line in lines
        {
            for run in line.glyphRuns + (line.marker?.glyphRuns ?? [])
            {
                let font = try #require(fonts[run.font])
                let glyphs = run.glyphs.map { CGGlyph($0.identifier) }
                let positions = run.glyphs.map
                {
                    CGPoint(x: $0.position.x - line.baseline.x,
                            y: line.baseline.y - $0.position.y)
                }
                context.saveGState()
                context.translateBy(x: line.baseline.x, y: line.baseline.y)
                context.textMatrix = CGAffineTransform(scaleX: 1, y: -1)
                CTFontDrawGlyphs(font, glyphs, positions, glyphs.count, context)
                context.restoreGState()
            }
        }
    }
}
