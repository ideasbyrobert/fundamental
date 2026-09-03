import FundamentalLayout

package struct ViewportLineage: Equatable, Sendable
{
    package let layout: LayoutLineage
    package let generation: UInt64
    package let specification: ViewportSpecificationIdentity
}
