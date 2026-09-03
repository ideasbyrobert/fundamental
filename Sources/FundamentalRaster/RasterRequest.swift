import FundamentalViewport

package struct RasterRequest: Equatable, Sendable
{
    package let expectedViewportLineage: ViewportLineage
    package let generation: UInt64
    package let specification: RasterSpecificationIdentity

    package init(
        expectedViewportLineage: ViewportLineage,
        generation: UInt64,
        specification: RasterSpecificationIdentity
    )
    {
        self.expectedViewportLineage = expectedViewportLineage
        self.generation = generation
        self.specification = specification
    }
}
