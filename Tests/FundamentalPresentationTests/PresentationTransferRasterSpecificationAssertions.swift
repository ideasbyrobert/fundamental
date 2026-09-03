import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func expectRasterSpecification(
        _ source: RasterSpecificationIdentity,
        equals result: PresentationRasterSpecificationIdentity
    )
    {
        #expect(rectangleSignature(source.logicalBounds)
            == rectangleSignature(result.logicalBounds))
        #expect(pixelSignature(source.pixelBounds)
            == pixelSignature(result.pixelBounds))
        #expect(source.backingScale == result.backingScale)
        #expect(appearanceSignature(source.appearance)
            == appearanceSignature(result.appearance))
        #expect(source.colorSpace.name == result.colorSpace.name)
        #expect(source.colorSpace.profile == result.colorSpace.profile)
        #expect(source.colorSpace.componentCount
            == result.colorSpace.componentCount)
        expectPalette(source.palette, equals: result.palette)
        #expect(capacitySignature(source.capacities)
            == capacitySignature(result.capacities))
    }

    private func appearanceSignature(_ value: RasterAppearance) -> String
    {
        "\(value.luminosity):\(value.contrast)"
    }

    private func appearanceSignature(
        _ value: PresentationAppearance
    ) -> String
    {
        "\(value.luminosity):\(value.contrast)"
    }
}
