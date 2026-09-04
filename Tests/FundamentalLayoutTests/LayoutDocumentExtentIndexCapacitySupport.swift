import Testing

@testable import FundamentalLayout

extension LayoutDocumentExtentIndexTests
{
    func factCapacity(
        _ values: [LayoutBlockMeasurement]
    ) throws -> LayoutExtentIndexCapacity
    {
        let rows = values.reduce(0)
        {
            $0 + (tableFacts($1)?.rowCount ?? 0)
        }
        let cells = values.reduce(0)
        {
            $0 + (tableFacts($1)?.cellCount ?? 0)
        }
        return try capacity(
            blocks: values.count,
            extents: values.flatMap(\.extents).count,
            fonts: resolvedFonts(values).count,
            rows: rows,
            cells: cells
        )
    }

    func reducedCapacities(
        _ value: LayoutExtentIndexCapacity
    ) throws -> [LayoutExtentIndexCapacity]
    {
        let maxima = [
            value.maximumBlockCount,
            value.maximumExtentCount,
            value.maximumResolvedFontCount,
            value.maximumTableRowCount,
            value.maximumTableCellCount
        ]
        return try maxima.indices.map
        {
            position in
            var reduced = maxima
            reduced[position] -= 1
            return try #require(LayoutExtentIndexCapacity(
                maximumBlockCount: reduced[0],
                maximumExtentCount: reduced[1],
                maximumResolvedFontCount: reduced[2],
                maximumTableRowCount: reduced[3],
                maximumTableCellCount: reduced[4]
            ))
        }
    }
}
