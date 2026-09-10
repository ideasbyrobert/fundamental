import AppKit
import CoreText
import Testing

@testable import FundamentalLayout
@testable import FundamentalProjection

@MainActor
enum LayoutMarkerRasterFixture
{
    static func source(number: Int?) throws -> LayoutListMarkerSource
    {
        let numberValue = number ?? 1
        let position = try #require(ProjectedListPosition(
            index: numberValue - 1, count: numberValue
        ))
        return try #require(LayoutListMarkerSource(
            block: ProjectedBlockSource(
                blockID: LayoutFixture.blockID(0), ordinal: 0
            ),
            role: number == nil ? .bulleted(position) : .numbered(position)
        ))
    }

    static func font() throws -> NSFont
    {
        let descriptor = try #require(NSFont.systemFont(ofSize: 17)
            .fontDescriptor.withDesign(.serif))
        return try #require(NSFont(descriptor: descriptor, size: 17))
    }

    static func image(scale: Double, draw: (CGContext) -> Void)
        throws -> CGImage
    {
        let width = Int(256 * scale)
        let height = Int(64 * scale)
        let context = try #require(CGContext(
            data: nil, width: width, height: height, bitsPerComponent: 8,
            bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ))
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: scale, y: -scale)
        context.setFillColor(CGColor(gray: 0, alpha: 1))
        context.setTextDrawingMode(.fill)
        context.textMatrix = CGAffineTransform(scaleX: 1, y: -1)
        draw(context)
        return try #require(context.makeImage())
    }

    static func draw(_ marker: LayoutListMarker, font: CTFont,
                     in context: CGContext)
    {
        for run in marker.glyphRuns
        {
            let glyphs = run.glyphs.map { CGGlyph($0.identifier) }
            let positions = run.glyphs.map
            {
                CGPoint(x: $0.position.x, y: -$0.position.y)
            }
            CTFontDrawGlyphs(font, glyphs, positions, glyphs.count, context)
        }
    }
}
