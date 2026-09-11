@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import CoreGraphics
import Foundation

struct SpacingRaster
{
    let image: CGImage
    let bytes: Data
    let width: Int
    let height: Int
    let scale: Double

    init(
        width: Double, height: Double, scale: Double,
        draw: (CGContext) throws -> Void
    ) throws
    {
        guard [width, height, scale].allSatisfy({ $0.isFinite && $0 > 0 }),
              width * scale <= 8192, height * scale <= 8192,
              let space = CGColorSpace(name: CGColorSpace.sRGB)
        else
        {
            throw SpacingRasterFailure.invalidRaster
        }
        let pixelsWide = Int(ceil(width * scale))
        let pixelsHigh = Int(ceil(height * scale))
        guard let context = CGContext(
            data: nil, width: pixelsWide, height: pixelsHigh,
            bitsPerComponent: 8, bytesPerRow: pixelsWide * 4, space: space,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
                | CGBitmapInfo.byteOrder32Big.rawValue
        )
        else
        {
            throw SpacingRasterFailure.invalidRaster
        }
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: pixelsWide, height: pixelsHigh))
        context.scaleBy(x: scale, y: scale)
        context.setShouldAntialias(true)
        context.setShouldSmoothFonts(false)
        try draw(context)
        guard let image = context.makeImage(), let data = context.data
        else
        {
            throw SpacingRasterFailure.missingImage
        }
        self.image = image
        bytes = Data(bytes: data, count: context.bytesPerRow * pixelsHigh)
        self.width = pixelsWide
        self.height = pixelsHigh
        self.scale = scale
    }
}
