import Foundation

extension NativeTextKit2Layout
{
    func measuredCells(
        _ placements: [NativeGridPlacement],
        blockID: UUID,
        columnExtent: Double,
        parameters: LayoutParameters
    ) throws -> [NativeMeasuredCell]
    {
        try placements.map
        {
            placement in
            let span = Double(placement.columnSpan)
            let width = columnExtent * span
                + parameters.columnSpacing * (span - 1)
                - parameters.cellPadding * 2
            guard width.isFinite,
                  width > 0
            else
            {
                throw LayoutFailure.nonfiniteNativeGeometry
            }
            return NativeMeasuredCell(
                placement: placement,
                lines: try textLines(
                    runs: placement.runs,
                    width: width,
                    originX: 0,
                    originY: 0,
                    font: try tableFont(placement.scope),
                    pointContext: .cell(
                        blockID: blockID,
                        row: placement.sourceRow,
                        cell: placement.sourceCell
                    )
                )
            )
        }
    }

    func rowHeights(
        _ cells: [NativeMeasuredCell],
        count: Int,
        parameters: LayoutParameters
    ) throws -> [Double]
    {
        let base = parameters.cellPadding * 2
        guard base.isFinite
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        var heights = [Double](repeating: base, count: count)
        for cell in cells where cell.placement.rowSpan == 1
        {
            let required = try requiredHeight(
                cell,
                padding: parameters.cellPadding
            )
            let row = cell.placement.rowTrack
            heights[row] = max(heights[row], required)
        }
        for cell in cells where cell.placement.rowSpan > 1
        {
            let start = cell.placement.rowTrack
            let end = start + cell.placement.rowSpan
            let occupied = heights[start ..< end].reduce(0, +)
                + parameters.rowSpacing
                    * Double(cell.placement.rowSpan - 1)
            let required = try requiredHeight(
                cell,
                padding: parameters.cellPadding
            )
            let deficit = max(0, required - occupied)
            let addition = deficit / Double(cell.placement.rowSpan)
            for row in start ..< end
            {
                heights[row] += addition
            }
        }
        guard heights.allSatisfy(\.isFinite)
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        return heights
    }

    func requiredHeight(
        _ cell: NativeMeasuredCell,
        padding: Double
    ) throws -> Double
    {
        let top = cell.lines.map(\.frame.minY).min() ?? 0
        let bottom = cell.lines.map(\.frame.maxY).max() ?? 0
        let result = bottom - top + padding * 2
        guard result.isFinite,
              result >= 0
        else
        {
            throw LayoutFailure.nonfiniteNativeGeometry
        }
        return result
    }
}
