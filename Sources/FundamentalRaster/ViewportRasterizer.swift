import FundamentalViewport

package struct ViewportRasterizer
{
    package init()
    {
    }

    package func rasterize(
        _ viewport: ViewportSnapshot,
        request: RasterRequest
    ) -> RasterSnapshot?
    {
        guard viewport.lineage == request.expectedViewportLineage,
              let documentSize = RasterSize(
                  width: viewport.documentSize.width,
                  height: viewport.documentSize.height
              ),
              let targetBounds = Self.targetBounds(
                  viewport,
                  documentSize: documentSize
              ),
              targetBounds == request.specification.logicalBounds,
              Self.admits(
                  viewport,
                  targetBounds: targetBounds,
                  capacities: request.specification.capacities
              )
        else
        {
            return nil
        }
        var accumulator = RasterAccumulator(
            capacities: request.specification.capacities
        )
        var ruleOwners: [RasterResidentID: RasterResidentID] = [:]
        let (count, overflow) = viewport.residents.remaining.count
            .addingReportingOverflow(1)
        guard !overflow
        else
        {
            return nil
        }
        for index in 0 ..< count
        {
            let resident = index == 0
                ? viewport.residents.first
                : viewport.residents.remaining[index - 1]
            guard Self.append(
                resident,
                targetBounds: targetBounds,
                specification: request.specification,
                ruleOwners: &ruleOwners,
                accumulator: &accumulator
            )
            else
            {
                return nil
            }
        }
        return Self.snapshot(
            viewport: viewport,
            request: request,
            documentSize: documentSize,
            ruleOwners: ruleOwners,
            accumulator: accumulator
        )
    }

    private static func snapshot(
        viewport: ViewportSnapshot,
        request: RasterRequest,
        documentSize: RasterSize,
        ruleOwners: [RasterResidentID: RasterResidentID],
        accumulator: RasterAccumulator
    ) -> RasterSnapshot?
    {
        guard let firstRegion = accumulator.regions.first
        else
        {
            return nil
        }
        let identifiers = accumulator.regions.map(\.residentID)
        let identifierSet = Set(identifiers)
        let source = viewport.sourceAnchor.fragment
        let residentAnchorID = RasterResidentID(
            blockID: source.blockID,
            blockOrdinal: source.blockOrdinal,
            fragmentOrdinal: source.fragmentOrdinal
        )
        let anchorID = ruleOwners[residentAnchorID]
            ?? residentAnchorID
        let relativeX: Double
        let relativeY: Double
        if anchorID != residentAnchorID,
           let owner = accumulator.regions.first(where:
           {
               $0.residentID == anchorID
           })
        {
            relativeX = owner.frame.minX - viewport.visibleBounds.minX
            relativeY = owner.frame.minY - viewport.visibleBounds.minY
        }
        else
        {
            relativeX = viewport.sourceAnchor.relativeX
            relativeY = viewport.sourceAnchor.relativeY
        }
        guard identifierSet.count == identifiers.count,
              accumulator.marks.allSatisfy(
                  { identifierSet.contains($0.residentID) }
              ),
              identifierSet.contains(anchorID)
        else
        {
            return nil
        }
        return RasterSnapshot(
            lineage: RasterLineage(
                viewport: viewport.lineage,
                generation: request.generation,
                specification: request.specification
            ),
            documentSize: documentSize,
            sourceAnchor: RasterSourceAnchor(
                residentID: anchorID,
                relativeX: relativeX,
                relativeY: relativeY
            ),
            marks: accumulator.marks,
            interactionMap: RasterInteractionMap(
                firstRegion: firstRegion,
                remainingRegions: Array(
                    accumulator.regions.dropFirst()
                )
            )
        )
    }
}
