import FundamentalViewport

extension SummitRasterPreparation
{
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
}
