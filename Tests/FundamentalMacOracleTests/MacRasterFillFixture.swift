import FundamentalPresentation
import Testing

@testable import FundamentalPresentation

enum MacRasterFillFixture
{
    static func overlapping(
        in source: PresentationSnapshot
    ) throws -> (
        pixels: PresentationPixelBounds,
        first: PresentationFill,
        second: PresentationFill
    )
    {
        let document = source.presentedDocument
        let origin = try #require(PresentationPoint(x: 24, y: 24))
        let size = try #require(PresentationSize(width: 40, height: 40))
        let bounds = try #require(PresentationRectangle(
            origin: origin,
            size: size
        ))
        let pixels = try #require(PresentationPixelBounds(
            logicalBounds: bounds,
            backingScale: document.plane.backingScale
        ))
        let count = document.plane.colorSpace.componentCount
        let dark = try #require(PresentationColor(
            colorSpace: document.plane.colorSpace,
            components: Array(repeating: 0, count: count),
            alpha: 1
        ))
        let bright = try #require(PresentationColor(
            colorSpace: document.plane.colorSpace,
            components: [1] + Array(repeating: 0, count: count - 1),
            alpha: 1
        ))
        let identifier = document.residents.first.residentID
        let first = PresentationFill(
            residentID: identifier,
            role: .headerBackground,
            logicalBounds: bounds,
            pixelBounds: pixels,
            color: dark,
            sourceSlices: []
        )
        let second = PresentationFill(
            residentID: identifier,
            role: .tableRule,
            logicalBounds: bounds,
            pixelBounds: pixels,
            color: bright,
            sourceSlices: []
        )
        return (pixels, first, second)
    }
}
