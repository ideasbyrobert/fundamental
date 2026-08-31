struct SemanticTableCellExtent: Equatable, Sendable
{
    let rowCount: Int
    let columnCount: Int

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
