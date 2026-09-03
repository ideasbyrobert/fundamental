import FundamentalProjection

package struct LayoutLineage: Equatable, Sendable
{
    package let projection: ProjectionLineage
    package let generation: UInt64
    package let specification: LayoutSpecificationIdentity
}
