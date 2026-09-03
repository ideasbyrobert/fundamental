@testable import FundamentalPresentation
@testable import FundamentalRaster

extension PresentationTransferTests
{
    func capacitySignature(_ value: RasterCapacities) -> [Int]
    {
        [
            value.marks,
            value.glyphs,
            value.fills,
            value.sourceSlices,
            value.caretSites,
            value.interactionRegions,
            value.fontVariations,
            value.residentUTF16Units,
            value.pixelArea
        ]
    }

    func capacitySignature(
        _ value: PresentationRasterCapacities
    ) -> [Int]
    {
        [
            value.marks,
            value.glyphs,
            value.fills,
            value.sourceSlices,
            value.caretSites,
            value.interactionRegions,
            value.fontVariations,
            value.residentUTF16Units,
            value.pixelArea
        ]
    }
}
