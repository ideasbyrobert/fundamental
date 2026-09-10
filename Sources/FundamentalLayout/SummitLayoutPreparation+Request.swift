import FundamentalProjection

extension SummitLayoutPreparation
{
    static func request(
        measure: Double,
        generation: UInt64
    ) -> LayoutRequest?
    {
        LayoutRequest(
            generation: generation,
            width: measure,
            blockSpacing: 18,
            rowSpacing: 6,
            columnSpacing: 10,
            cellPadding: 8
        )
    }

    static func summitCapacity() -> LayoutExtentIndexCapacity?
    {
        LayoutExtentIndexCapacity(
            maximumBlockCount: 100_000,
            maximumExtentCount: 1_000_000,
            maximumResolvedFontCount: 4_096,
            maximumTableRowCount: 100_000,
            maximumTableCellCount: 100_000
        )
    }
}
