struct LayoutTableMeasurement: Equatable, Sendable
{
    let rowCount: Int
    let cellCount: Int
    let structuralFont: LayoutFontIdentity

    init?(
        rowCount: Int,
        cellCount: Int,
        structuralFont: LayoutFontIdentity
    )
    {
        guard rowCount >= 0,
              cellCount >= 0
        else
        {
            return nil
        }
        self.rowCount = rowCount
        self.cellCount = cellCount
        self.structuralFont = structuralFont
    }
}
