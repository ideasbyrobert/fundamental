import FundamentalProjection

package struct LayoutColumnTrack: Equatable, Sendable
{
    package let index: Int
    package let alignment: ProjectedTableColumnAlignment
    package let origin: Double
    package let extent: Double
}
