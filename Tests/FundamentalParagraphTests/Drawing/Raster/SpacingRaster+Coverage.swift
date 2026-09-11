@testable import FundamentalNativeParagraph
@testable import FundamentalParagraph
import CoreGraphics

extension SpacingRaster
{
    var coveredPixels: Int
    {
        stride(from: 0, to: bytes.count, by: 4).count
        {
            bytes[$0] != 255 || bytes[$0 + 1] != 255 || bytes[$0 + 2] != 255
        }
    }

    var pixelBounds: CGRect
    {
        var lowerX = width
        var lowerY = height
        var upperX = -1
        var upperY = -1
        for index in stride(from: 0, to: bytes.count, by: 4)
            where bytes[index] != 255 || bytes[index + 1] != 255
                || bytes[index + 2] != 255
        {
            let pixel = index / 4
            let x = pixel % width
            let y = pixel / width
            lowerX = min(lowerX, x)
            lowerY = min(lowerY, y)
            upperX = max(upperX, x)
            upperY = max(upperY, y)
        }
        if upperX < 0
        {
            return .null
        }
        return CGRect(
            x: lowerX, y: lowerY,
            width: upperX - lowerX + 1, height: upperY - lowerY + 1
        )
    }
}
