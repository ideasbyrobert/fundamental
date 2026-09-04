import FundamentalLayout

@MainActor
package final class SummitViewportPreparation
{
    private static let maximumCompleteBlockFragmentCount = 100_000
    private static let maximumRichFactCount = 1_000_000
    private static let maximumResidentUTF16UnitCount = 2_000_000
    private let layoutPreparation: SummitLayoutPreparation

    package init?()
    {
        guard let preparation = SummitLayoutPreparation()
        else
        {
            return nil
        }
        layoutPreparation = preparation
    }

    init(layoutPreparation: SummitLayoutPreparation)
    {
        self.layoutPreparation = layoutPreparation
    }

    package var layoutExecutionCount: Int
    {
        layoutPreparation.executionCount
    }

    package func viewport(
        generation: UInt64,
        readableMeasure: Double,
        visibleOriginY: Double,
        visibleHeight: Double,
        overscanExtent: Double,
        maximumResidentCount: Int
    ) -> ViewportSnapshot?
    {
        viewportDiagnostics(
            generation: generation,
            readableMeasure: readableMeasure,
            visibleOriginY: visibleOriginY,
            visibleHeight: visibleHeight,
            overscanExtent: overscanExtent,
            maximumResidentCount: maximumResidentCount
        )?.snapshot
    }

    func viewportDiagnostics(
        generation: UInt64,
        readableMeasure: Double,
        visibleOriginY: Double,
        visibleHeight: Double,
        overscanExtent: Double,
        maximumResidentCount: Int
    ) -> ViewportWindowAdmissionDiagnostics?
    {
        guard readableMeasure.isFinite,
              readableMeasure > 0,
              visibleOriginY.isFinite,
              visibleHeight.isFinite,
              visibleOriginY >= 0,
              visibleHeight > 0,
              overscanExtent.isFinite,
              overscanExtent >= 0,
              maximumResidentCount > 0,
              let capacity = Self.materializationCapacity(
                  maximumResidentCount: maximumResidentCount
              ),
              let indexed = layoutPreparation.indexedProjection(
                  readableMeasure: readableMeasure
              )
        else
        {
            return nil
        }
        let maximumOrigin = max(
            0,
            indexed.documentSize.height - visibleHeight
        )
        let admittedOrigin = min(visibleOriginY, maximumOrigin)
        guard let origin = LayoutPoint(
                  x: 0,
                  y: admittedOrigin
              ),
              let size = LayoutSize(
                  width: indexed.documentSize.width,
                  height: visibleHeight
              ),
              let bounds = LayoutRectangle(
                  origin: origin,
                  size: size
              ),
              let request = ViewportRequest(
                  expectedLayoutLineage: indexed.lineage,
                  generation: generation,
                  visibleBounds: bounds,
                  precedingOverscanExtent: overscanExtent,
                  followingOverscanExtent: overscanExtent,
                  maximumResidentCount: maximumResidentCount
              )
        else
        {
            return nil
        }
        return try? ViewportSnapshot.windowAdmissionDiagnostics(
            indexed,
            request: request,
            capacity: capacity
        )
    }

    private static func materializationCapacity(
        maximumResidentCount: Int
    ) -> LayoutMaterializationCapacity?
    {
        LayoutMaterializationCapacity(
            reconstructedBlocks: maximumResidentCount,
            reconstructedFragments: maximumCompleteBlockFragmentCount,
            materializedFragments: maximumResidentCount,
            glyphs: maximumRichFactCount,
            caretStops: maximumRichFactCount,
            sourceSlices: maximumRichFactCount,
            decorations: maximumRichFactCount,
            fontVariations: maximumRichFactCount,
            residentUTF16Units: maximumResidentUTF16UnitCount
        )
    }
}
