import FundamentalDocument

package struct ProjectedTableCellExtent: Equatable, Sendable
{
    package let rowCount: Int
    package let columnCount: Int

    init(_ extent: SemanticTableCellExtent)
    {
        rowCount = extent.rowCount
        columnCount = extent.columnCount
    }
}
