import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func expectPalette(
        _ source: RasterPalette,
        equals result: PresentationPalette
    )
    {
        expectColor(source.documentBackground,
            equals: result.documentBackground)
        expectColor(source.tableBackground,
            equals: result.tableBackground)
        expectColor(source.headerBackground,
            equals: result.headerBackground)
        expectColor(source.rule, equals: result.rule)
        expectColor(source.text, equals: result.text)
        expectColor(source.decoration, equals: result.decoration)
    }

    func expectColor(
        _ source: RasterColor,
        equals result: PresentationColor
    )
    {
        #expect(source.colorSpace.name == result.colorSpace.name)
        #expect(source.colorSpace.profile == result.colorSpace.profile)
        #expect(source.colorSpace.componentCount
            == result.colorSpace.componentCount)
        #expect(source.components == result.components)
        #expect(source.alpha == result.alpha)
    }
}
