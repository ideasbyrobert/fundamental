import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func expectRegion(
        _ source: RasterInteractionRegion,
        equals result: PresentedResident
    )
    {
        #expect(source.residentID.blockID == result.residentID.blockID)
        #expect(source.residentID.blockOrdinal
            == result.residentID.blockOrdinal)
        #expect(source.residentID.fragmentOrdinal
            == result.residentID.fragmentOrdinal)
        #expect(rectangleSignature(source.frame)
            == rectangleSignature(result.frame))
        #expect(residenceSignature(source.residence)
            == residenceSignature(result.residence))
        expectContent(
            source.content,
            role: source.role,
            equals: result.content
        )
    }

    private func residenceSignature(_ value: RasterResidence) -> String
    {
        switch value
        {
        case .visible:
            "visible"
        case .overscan(.preceding):
            "preceding"
        case .overscan(.following):
            "following"
        }
    }

    private func residenceSignature(
        _ value: PresentationResidence
    ) -> String
    {
        switch value
        {
        case .visible:
            "visible"
        case .overscan(.preceding):
            "preceding"
        case .overscan(.following):
            "following"
        }
    }
}
