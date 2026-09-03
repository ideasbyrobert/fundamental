@testable import FundamentalLayout
@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func rectangleSignature(_ value: LayoutRectangle) -> [Double]
    {
        [value.minX, value.minY, value.size.width, value.size.height]
    }

    func rectangleSignature(_ value: RasterRectangle) -> [Double]
    {
        [value.minX, value.minY, value.size.width, value.size.height]
    }

    func rectangleSignature(_ value: PresentationRectangle) -> [Double]
    {
        [value.minX, value.minY, value.size.width, value.size.height]
    }

    func pixelSignature(_ value: RasterPixelBounds) -> [Int]
    {
        [
            value.minimumX,
            value.minimumY,
            value.maximumX,
            value.maximumY,
            value.width,
            value.height,
            value.area
        ]
    }

    func pixelSignature(_ value: PresentationPixelBounds) -> [Int]
    {
        [
            value.minimumX,
            value.minimumY,
            value.maximumX,
            value.maximumY,
            value.width,
            value.height,
            value.area
        ]
    }
}
