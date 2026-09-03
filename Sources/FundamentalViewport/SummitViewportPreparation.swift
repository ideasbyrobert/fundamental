import FundamentalLayout

@MainActor
package final class SummitViewportPreparation
{
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
        guard let layout = layoutPreparation.layout(
            readableMeasure: readableMeasure
        ),
              visibleOriginY.isFinite,
              visibleHeight.isFinite,
              visibleOriginY >= 0,
              visibleHeight > 0,
              overscanExtent.isFinite,
              overscanExtent >= 0,
              maximumResidentCount > 0
        else
        {
            return nil
        }
        let maximumOrigin = max(0, layout.size.height - visibleHeight)
        let admittedOrigin = min(visibleOriginY, maximumOrigin)
        guard let origin = LayoutPoint(
                  x: 0,
                  y: admittedOrigin
              ),
              let size = LayoutSize(
                  width: layout.size.width,
                  height: visibleHeight
              ),
              let bounds = LayoutRectangle(
                  origin: origin,
                  size: size
              ),
              let request = ViewportRequest(
                  expectedLayoutLineage: layout.lineage,
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
        return ViewportSnapshot(layout, request: request)
    }
}
