import FundamentalLayout

package struct ViewportSpecificationIdentity: Equatable, Sendable
{
    package let visibleBounds: LayoutRectangle
    package let precedingOverscanExtent: Double
    package let followingOverscanExtent: Double
    package let maximumResidentCount: Int

    init?(
        visibleBounds: LayoutRectangle,
        precedingOverscanExtent: Double,
        followingOverscanExtent: Double,
        maximumResidentCount: Int
    )
    {
        guard visibleBounds.size.width > 0,
              visibleBounds.size.height > 0,
              precedingOverscanExtent.isFinite,
              followingOverscanExtent.isFinite,
              precedingOverscanExtent >= 0,
              followingOverscanExtent >= 0,
              maximumResidentCount > 0,
              (visibleBounds.minY - precedingOverscanExtent).isFinite,
              (visibleBounds.maxY + followingOverscanExtent).isFinite
        else
        {
            return nil
        }
        self.visibleBounds = visibleBounds
        self.precedingOverscanExtent = precedingOverscanExtent == 0
            ? 0
            : precedingOverscanExtent
        self.followingOverscanExtent = followingOverscanExtent == 0
            ? 0
            : followingOverscanExtent
        self.maximumResidentCount = maximumResidentCount
    }
}
