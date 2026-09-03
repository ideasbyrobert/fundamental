import Testing

@testable import FundamentalPresentation

extension PresentationTransferTests
{
    @MainActor
    @Test("every bounded table resident fact transfers exactly")
    func tableStructure() throws
    {
        let raster = try PresentationFixture.raster(
            PresentationFixture.viewport(
                PresentationFixture.layout([
                    PresentationFixture.table()
                ], width: 360)
            )
        )
        let document = try PresentationFixture.snapshot(raster)
            .presentedDocument
        let source = raster.interactionMap.regions
        let result = document.residents.all
        #expect(source.count == result.count)
        for pair in zip(source, result)
        {
            expectRegion(pair.0, equals: pair.1)
        }
    }
}
