import FundamentalLayout

package struct ViewportRequest: Equatable, Sendable
{
    package let expectedLayoutLineage: LayoutLineage
    package let generation: UInt64
    package let specification: ViewportSpecificationIdentity

    package var visibleBounds: LayoutRectangle
    {
        specification.visibleBounds
    }

    package var precedingOverscanExtent: Double
    {
        specification.precedingOverscanExtent
    }

    package var followingOverscanExtent: Double
    {
        specification.followingOverscanExtent
    }

    package var maximumResidentCount: Int
    {
        specification.maximumResidentCount
    }

    package init?(
        expectedLayoutLineage: LayoutLineage,
        generation: UInt64,
        visibleBounds: LayoutRectangle,
        precedingOverscanExtent: Double,
        followingOverscanExtent: Double,
        maximumResidentCount: Int
    )
    {
        guard let specification = ViewportSpecificationIdentity(
            visibleBounds: visibleBounds,
            precedingOverscanExtent: precedingOverscanExtent,
            followingOverscanExtent: followingOverscanExtent,
            maximumResidentCount: maximumResidentCount
        )
        else
        {
            return nil
        }
        self.expectedLayoutLineage = expectedLayoutLineage
        self.generation = generation
        self.specification = specification
    }
}
