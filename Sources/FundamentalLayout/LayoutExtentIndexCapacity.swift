struct LayoutExtentIndexCapacity: Equatable, Sendable
{
    let maximumBlockCount: Int
    let maximumExtentCount: Int
    let maximumResolvedFontCount: Int
    let maximumTableRowCount: Int
    let maximumTableCellCount: Int

    init?(
        maximumBlockCount: Int,
        maximumExtentCount: Int,
        maximumResolvedFontCount: Int,
        maximumTableRowCount: Int,
        maximumTableCellCount: Int
    )
    {
        let values = [
            maximumBlockCount,
            maximumExtentCount,
            maximumResolvedFontCount,
            maximumTableRowCount,
            maximumTableCellCount
        ]
        guard values.allSatisfy({ $0 > 0 })
        else
        {
            return nil
        }
        self.maximumBlockCount = maximumBlockCount
        self.maximumExtentCount = maximumExtentCount
        self.maximumResolvedFontCount = maximumResolvedFontCount
        self.maximumTableRowCount = maximumTableRowCount
        self.maximumTableCellCount = maximumTableCellCount
    }
}
