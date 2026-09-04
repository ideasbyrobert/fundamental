import FundamentalProjection

struct LayoutDocumentExtentIndex: Equatable, Sendable
{
    let lineage: LayoutLineage
    let size: LayoutSize
    let extents: [LayoutPlacedFragmentExtent]
    let spatialOrder: [Int]
    let spatialMaximumY: [Double]
    let spatialMaximumYPaintOrder: [Int]

    init?(
        projection: ProjectionSnapshot,
        request: LayoutRequest,
        capacity: LayoutExtentIndexCapacity,
        measurements: [LayoutBlockMeasurement]
    )
    {
        let blocks = projection.blocks
        guard blocks.count == measurements.count,
              blocks.count <= capacity.maximumBlockCount,
              Self.matches(blocks, measurements: measurements),
              let facts = Self.admitFacts(
                  measurements,
                  parameters: request.parameters,
                  capacity: capacity
              ),
              let placement = Self.place(
                  measurements,
                  blockSpacing: request.parameters.blockSpacing
              ),
              !placement.extents.isEmpty,
              let size = LayoutSize(
                  width: max(request.parameters.width, placement.maximumX),
                  height: placement.maximumY
              ),
              let spatial = Self.spatialIndex(placement.extents)
        else
        {
            return nil
        }
        lineage = LayoutLineage(
            projection: projection.lineage,
            generation: request.generation,
            specification: LayoutSpecificationIdentity(
                parameters: request.parameters,
                resolvedFonts: facts.fonts
            )
        )
        self.size = size
        extents = placement.extents
        spatialOrder = spatial.order
        spatialMaximumY = spatial.maximumY
        spatialMaximumYPaintOrder = spatial.maximumYPaintOrder
    }
}
