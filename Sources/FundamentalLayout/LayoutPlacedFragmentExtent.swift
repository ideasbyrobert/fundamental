import FundamentalProjection

struct LayoutPlacedFragmentExtent: Equatable, Sendable
{
    let localExtent: LayoutFragmentExtent
    let frame: LayoutRectangle

    var source: ProjectedBlockSource
    {
        localExtent.source
    }

    var anchor: LayoutFragmentAnchor
    {
        localExtent.anchor
    }

    var content: LayoutFragmentExtentContent
    {
        localExtent.content
    }

    init?(
        localExtent: LayoutFragmentExtent,
        documentOriginY: Double
    )
    {
        guard documentOriginY.isFinite,
              documentOriginY >= 0,
              let origin = LayoutPoint(
                  x: localExtent.frame.minX,
                  y: documentOriginY + localExtent.frame.minY
              ),
              let frame = LayoutRectangle(
                  origin: origin,
                  size: localExtent.frame.size
              )
        else
        {
            return nil
        }
        self.localExtent = localExtent
        self.frame = frame
    }
}
