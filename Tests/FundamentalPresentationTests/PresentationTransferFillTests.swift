import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    @MainActor
    @Test("every fill fact transfers exactly in global order")
    func fillEvidence() throws
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
        let source: [RasterFill] = raster.marks.compactMap
        {
            guard case let .fill(fill) = $0
            else
            {
                return nil
            }
            return fill
        }
        let result: [PresentationFill] = document.marks.compactMap
        {
            guard case let .fill(fill) = $0
            else
            {
                return nil
            }
            return fill
        }
        #expect(!source.isEmpty)
        #expect(source.count == result.count)
        for pair in zip(source, result)
        {
            expectFill(pair.0, equals: pair.1)
        }
    }
}
