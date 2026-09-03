import FundamentalViewport

@MainActor
package final class SummitRasterPreparation
{
    private let viewportPreparation: SummitViewportPreparation

    package init?()
    {
        guard let preparation = SummitViewportPreparation()
        else
        {
            return nil
        }
        viewportPreparation = preparation
    }

    package var layoutExecutionCount: Int
    {
        viewportPreparation.layoutExecutionCount
    }

    package func raster(
        generation: UInt64,
        readableMeasure: Double,
        visibleOriginY: Double,
        visibleHeight: Double,
        overscanExtent: Double,
        maximumResidentCount: Int,
        backingScale: Double,
        appearance: RasterAppearance,
        colorSpace: RasterColorSpaceIdentity,
        palette: RasterPalette,
        capacities: RasterCapacities
    ) -> RasterSnapshot?
    {
        guard let viewport = viewportPreparation.viewport(
            generation: generation,
            readableMeasure: readableMeasure,
            visibleOriginY: visibleOriginY,
            visibleHeight: visibleHeight,
            overscanExtent: overscanExtent,
            maximumResidentCount: maximumResidentCount
        ),
              let bounds = Self.targetBounds(viewport),
              let specification = RasterSpecificationIdentity(
                  logicalBounds: bounds,
                  backingScale: backingScale,
                  appearance: appearance,
                  colorSpace: colorSpace,
                  palette: palette,
                  capacities: capacities
              )
        else
        {
            return nil
        }
        let request = RasterRequest(
            expectedViewportLineage: viewport.lineage,
            generation: generation,
            specification: specification
        )
        return ViewportRasterizer().rasterize(
            viewport,
            request: request
        )
    }

    private static func targetBounds(
        _ viewport: ViewportSnapshot
    ) -> RasterRectangle?
    {
        let specification = viewport.lineage.specification
        let minimumY = max(
            0,
            specification.visibleBounds.minY
                - specification.precedingOverscanExtent
        )
        let maximumY = min(
            viewport.documentSize.height,
            specification.visibleBounds.maxY
                + specification.followingOverscanExtent
        )
        guard maximumY > minimumY,
              let origin = RasterPoint(x: 0, y: minimumY),
              let size = RasterSize(
                  width: viewport.documentSize.width,
                  height: maximumY - minimumY
              )
        else
        {
            return nil
        }
        return RasterRectangle(origin: origin, size: size)
    }
}
