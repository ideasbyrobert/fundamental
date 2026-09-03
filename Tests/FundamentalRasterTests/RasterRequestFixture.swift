import Testing

@testable import FundamentalRaster
@testable import FundamentalViewport

extension RasterFixture
{
    static func specification(
        _ viewport: ViewportSnapshot,
        scale: Double = 2,
        capacities: RasterCapacities? = nil,
        luminosity: RasterLuminosity = .light,
        contrast: RasterContrast = .standard
    ) throws -> RasterSpecificationIdentity
    {
        try #require(RasterSpecificationIdentity(
            logicalBounds: targetBounds(viewport),
            backingScale: scale,
            appearance: RasterAppearance(
                luminosity: luminosity,
                contrast: contrast
            ),
            colorSpace: colorSpace(),
            palette: palette(),
            capacities: capacities ?? self.capacities()
        ))
    }

    static func request(
        _ viewport: ViewportSnapshot,
        generation: UInt64 = 17,
        capacities: RasterCapacities? = nil
    ) throws -> RasterRequest
    {
        RasterRequest(
            expectedViewportLineage: viewport.lineage,
            generation: generation,
            specification: try specification(
                viewport,
                capacities: capacities
            )
        )
    }

    static func snapshot(
        _ viewport: ViewportSnapshot,
        capacities: RasterCapacities? = nil
    ) throws -> RasterSnapshot
    {
        try #require(ViewportRasterizer().rasterize(
            viewport,
            request: request(
                viewport,
                capacities: capacities
            )
        ))
    }
}
