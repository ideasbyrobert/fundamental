import FundamentalProjection

package struct LayoutCell: Equatable, Sendable
{
    package let scope: LayoutTableRowScope
    package let sourceRow: Int
    package let sourceCell: Int
    package let rowTrack: Int
    package let columnTrack: Int
    package let rowSpan: Int
    package let columnSpan: Int
    package let projectedAlignment: ProjectedTableColumnAlignment
    package let resolvedAlignment: ProjectedTableColumnAlignment
    package let frame: LayoutRectangle
}
