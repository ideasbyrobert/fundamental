import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func expectFill(
        _ source: RasterFill,
        equals result: PresentationFill
    )
    {
        #expect(source.residentID.blockID == result.residentID.blockID)
        #expect(source.residentID.blockOrdinal
            == result.residentID.blockOrdinal)
        #expect(source.residentID.fragmentOrdinal
            == result.residentID.fragmentOrdinal)
        #expect(fillRoleSignature(source.role)
            == fillRoleSignature(result.role))
        #expect(rectangleSignature(source.logicalBounds)
            == rectangleSignature(result.logicalBounds))
        #expect(pixelSignature(source.pixelBounds)
            == pixelSignature(result.pixelBounds))
        #expect(source.color.colorSpace.name
            == result.color.colorSpace.name)
        #expect(source.color.colorSpace.profile
            == result.color.colorSpace.profile)
        #expect(source.color.colorSpace.componentCount
            == result.color.colorSpace.componentCount)
        #expect(source.color.components == result.color.components)
        #expect(source.color.alpha == result.color.alpha)
        expectSlices(source.sourceSlices, equals: result.sourceSlices)
    }

    private func fillRoleSignature(_ value: RasterFillRole) -> Int
    {
        switch value
        {
        case .tableBackground: 0
        case .headerBackground: 1
        case .tableRule: 2
        case .underline: 3
        case .strikethrough: 4
        }
    }

    private func fillRoleSignature(_ value: PresentationFillRole) -> Int
    {
        switch value
        {
        case .tableBackground: 0
        case .headerBackground: 1
        case .tableRule: 2
        case .underline: 3
        case .strikethrough: 4
        }
    }
}
