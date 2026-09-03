import Testing

@testable import FundamentalRaster
@testable import FundamentalViewport

extension PresentationFixture
{
    static func raster(
        _ viewport: ViewportSnapshot,
        generation: UInt64 = 17,
        scale: Double = 2,
        profile: [UInt8] = [1, 2, 3],
        documentBackground: Double = 1
    ) throws -> RasterSnapshot
    {
        let colorSpace = try #require(RasterColorSpaceIdentity(
            name: "Test RGB",
            profile: profile,
            componentCount: 3
        ))
        func color(_ value: Double) throws -> RasterColor
        {
            try #require(RasterColor(
                colorSpace: colorSpace,
                components: [value, value, value],
                alpha: 1
            ))
        }
        let palette = try #require(RasterPalette(
            documentBackground: color(documentBackground),
            tableBackground: color(0.9),
            headerBackground: color(0.8),
            rule: color(0.4),
            text: color(0.1),
            decoration: color(0.2)
        ))
        let specification = try #require(RasterSpecificationIdentity(
            logicalBounds: try rasterBounds(viewport),
            backingScale: scale,
            appearance: RasterAppearance(
                luminosity: .light,
                contrast: .standard
            ),
            colorSpace: colorSpace,
            palette: palette,
            capacities: try rasterCapacities()
        ))
        return try #require(ViewportRasterizer().rasterize(
            viewport,
            request: RasterRequest(
                expectedViewportLineage: viewport.lineage,
                generation: generation,
                specification: specification
            )
        ))
    }

    private static func rasterCapacities() throws -> RasterCapacities
    {
        try #require(RasterCapacities(
            marks: 1_000_000,
            glyphs: 1_000_000,
            fills: 1_000_000,
            sourceSlices: 1_000_000,
            caretSites: 1_000_000,
            interactionRegions: 1_000_000,
            fontVariations: 1_000_000,
            residentUTF16Units: 1_000_000,
            pixelArea: 1_000_000
        ))
    }
}
