import Testing

@testable import FundamentalPresentation
@testable import FundamentalRaster

enum PresentationFixture
{
    static func specification(
        _ raster: RasterSnapshot,
        selectionCapacity: Int = 100,
        caretWidth: Double = 1
    ) throws -> PresentationSpecificationIdentity
    {
        let lineage = try #require(
            PresentationComposer().rasterLineage(of: raster)
        )
        let space = lineage.specification.colorSpace
        let caret = try #require(PresentationColor(
            colorSpace: space,
            components: [0.1, 0.2, 0.3],
            alpha: 1
        ))
        let selection = try #require(PresentationColor(
            colorSpace: space,
            components: [0.3, 0.4, 0.5],
            alpha: 0.4
        ))
        let palette = try #require(PresentationAdornmentPalette(
            caret: caret,
            selection: selection
        ))
        return try #require(PresentationSpecificationIdentity(
            caretWidth: caretWidth,
            adornmentPalette: palette,
            maximumSelectionFragmentCount: selectionCapacity
        ))
    }

    static func request(
        _ raster: RasterSnapshot,
        intent: PresentationIntent = .document,
        generation: UInt64 = 19,
        selectionCapacity: Int = 100
    ) throws -> PresentationRequest
    {
        let composer = PresentationComposer()
        return PresentationRequest(
            expectedRasterLineage: try #require(
                composer.rasterLineage(of: raster)
            ),
            generation: generation,
            specification: try specification(
                raster,
                selectionCapacity: selectionCapacity
            ),
            intent: intent
        )
    }

    static func snapshot(
        _ raster: RasterSnapshot,
        intent: PresentationIntent = .document,
        generation: UInt64 = 19,
        selectionCapacity: Int = 100
    ) throws -> PresentationSnapshot
    {
        try #require(PresentationComposer().present(
            raster,
            request: request(
                raster,
                intent: intent,
                generation: generation,
                selectionCapacity: selectionCapacity
            )
        ))
    }
}
