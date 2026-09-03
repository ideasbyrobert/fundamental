package struct LayoutParameters: Equatable, Hashable, Sendable
{
    package let width: Double
    package let blockSpacing: Double
    package let rowSpacing: Double
    package let columnSpacing: Double
    package let cellPadding: Double

    init?(
        width: Double,
        blockSpacing: Double,
        rowSpacing: Double,
        columnSpacing: Double,
        cellPadding: Double
    )
    {
        let values = [
            width,
            blockSpacing,
            rowSpacing,
            columnSpacing,
            cellPadding
        ]
        guard values.allSatisfy(\.isFinite),
              width > 0,
              values.dropFirst().allSatisfy({ $0 >= 0 })
        else
        {
            return nil
        }
        self.width = width
        self.blockSpacing = blockSpacing == 0 ? 0 : blockSpacing
        self.rowSpacing = rowSpacing == 0 ? 0 : rowSpacing
        self.columnSpacing = columnSpacing == 0 ? 0 : columnSpacing
        self.cellPadding = cellPadding == 0 ? 0 : cellPadding
    }
}
