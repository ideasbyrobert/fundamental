import Testing

@testable import FundamentalRaster

extension PresentationFixture
{
    static func raster(
        _ raster: RasterSnapshot,
        replacingFirstCaretXs values: [Double]
    ) throws -> RasterSnapshot
    {
        let first = raster.interactionMap.firstRegion
        guard case let .text(text) = first.content
        else
        {
            throw PresentationTestError.missingSelection
        }
        let old = text.caretSites
        guard old.count == values.count
        else
        {
            throw PresentationTestError.missingSelection
        }
        let carets = try zip(old, values).map
        {
            RasterCaretSite(
                utf16Offset: $0.0.utf16Offset,
                position: try #require(RasterPoint(
                    x: $0.1,
                    y: $0.0.position.y
                )),
                sourcePoint: $0.0.sourcePoint
            )
        }
        let content = RasterInteractionText(
            text: text.text,
            defaultFont: text.defaultFont,
            lineBounds: text.lineBounds,
            baseline: text.baseline,
            sourceSlices: text.sourceSlices,
            firstCaretSite: carets[0],
            remainingCaretSites: Array(carets.dropFirst())
        )
        let region = RasterInteractionRegion(
            residentID: first.residentID,
            residence: first.residence,
            role: first.role,
            frame: first.frame,
            content: .text(content)
        )
        return RasterSnapshot(
            lineage: raster.lineage,
            documentSize: raster.documentSize,
            sourceAnchor: raster.sourceAnchor,
            marks: raster.marks,
            interactionMap: RasterInteractionMap(
                firstRegion: region,
                remainingRegions: raster.interactionMap.remainingRegions
            )
        )
    }
}
