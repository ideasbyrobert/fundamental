package struct SemanticTableCellExtent: Equatable, Sendable
{
    package let rowCount: Int
    package let columnCount: Int

    init?(
        rowCount: Int,
        columnCount: Int
    )
    {
        guard rowCount > 0,
              columnCount > 0,
              rowCount > 1 || columnCount > 1
        else
        {
            return nil
        }

        self.rowCount = rowCount
        self.columnCount = columnCount
    }
}
