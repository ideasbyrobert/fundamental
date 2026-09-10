import Testing

@testable import FundamentalRaster

extension PresentationListFixture
{
    static func replacing(
        _ raster: RasterSnapshot, regions: [RasterInteractionRegion]? = nil,
        marks: [RasterMark]? = nil
    ) throws -> RasterSnapshot
    {
        let regions = regions ?? raster.interactionMap.regions
        return RasterSnapshot(
            lineage: raster.lineage, documentSize: raster.documentSize,
            sourceAnchor: raster.sourceAnchor, marks: marks ?? raster.marks,
            interactionMap: RasterInteractionMap(
                firstRegion: try #require(regions.first),
                remainingRegions: Array(regions.dropFirst())
            )
        )
    }

    static func region(
        _ region: RasterInteractionRegion,
        role: RasterInteractionRole? = nil, marker: RasterListMarker?
    ) throws -> RasterInteractionRegion
    {
        guard case let .text(line) = region.content
        else
        {
            throw PresentationListTestFailure.missingText
        }
        return RasterInteractionRegion(
            residentID: region.residentID, residence: region.residence,
            role: role ?? region.role, frame: region.frame,
            content: .text(RasterInteractionText(
                text: line.text, defaultFont: line.defaultFont,
                lineBounds: line.lineBounds, baseline: line.baseline,
                marker: marker, sourceSlices: line.sourceSlices,
                firstCaretSite: line.firstCaretSite,
                remainingCaretSites: line.remainingCaretSites
            ))
        )
    }
}
