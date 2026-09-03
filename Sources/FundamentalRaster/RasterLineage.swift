import FundamentalViewport

package struct RasterLineage: Equatable, Sendable
{
    package let viewport: ViewportLineage
    package let generation: UInt64
    package let specification: RasterSpecificationIdentity
}
