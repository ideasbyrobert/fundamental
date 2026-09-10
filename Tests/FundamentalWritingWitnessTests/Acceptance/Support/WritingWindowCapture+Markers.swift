import AppKit
import Testing

@testable import FundamentalWritingWitness

extension WritingWindowCapture
{
    static func markerInk(
        _ rectangle: NSRect, in window: WritingTestWindow,
        bitmap: NSBitmapImageRep, background: NSBitmapImageRep
    ) throws -> Int
    {
        let root = try #require(window.controller.documentWindow.contentView)
        try #require(bitmap.pixelsWide == background.pixelsWide &&
                     bitmap.pixelsHigh == background.pixelsHigh)
        let frame = window.view.convert(rectangle, to: root)
        let scaleX = Double(bitmap.pixelsWide) / root.bounds.width
        let scaleY = Double(bitmap.pixelsHigh) / root.bounds.height
        let top = root.isFlipped ? frame.minY :
            root.bounds.height - frame.maxY
        let left = max(0, Int(floor(frame.minX * scaleX)))
        let right = min(bitmap.pixelsWide, Int(ceil(frame.maxX * scaleX)))
        let first = max(0, Int(floor(top * scaleY)))
        let last = min(bitmap.pixelsHigh,
                       Int(ceil((top + frame.height) * scaleY)))
        try #require(left < right && first < last)
        var ink = 0
        for y in first ..< last
        {
            for x in left ..< right
            {
                let pixel = try #require(bitmap.colorAt(x: x, y: y)?
                    .usingColorSpace(.deviceRGB))
                let plain = try #require(background.colorAt(x: x, y: y)?
                    .usingColorSpace(.deviceRGB))
                let difference = abs(pixel.redComponent - plain.redComponent) +
                    abs(pixel.greenComponent - plain.greenComponent) +
                    abs(pixel.blueComponent - plain.blueComponent)
                if difference > 0.3
                {
                    ink += 1
                }
            }
        }
        return ink
    }
}
