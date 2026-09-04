import FundamentalProjection

extension NativeTextKit2Layout
{
    func blockLayout(
        _ block: ProjectedBlock,
        originY: Double,
        parameters: LayoutParameters
    ) throws -> NativeBlockLayout
    {
        switch block
        {
        case let .prose(source, prose):
            let lines = try proseLines(
                prose,
                source: source,
                width: parameters.width,
                originY: originY
            )
            return NativeBlockLayout(
                kind: .prose(prose.role),
                fragments: try proseFragments(
                    lines: lines,
                    source: source,
                    role: prose.role,
                    width: parameters.width
                ),
                grids: [],
                maximumY: lines.map(\.frame.maxY).max() ?? originY
            )
        case let .code(source, code):
            let lines = try codeLines(
                code,
                source: source,
                width: parameters.width,
                originY: originY
            )
            return NativeBlockLayout(
                kind: .code,
                fragments: try codeFragments(
                    lines: lines,
                    source: source,
                    width: parameters.width
                ),
                grids: [],
                maximumY: lines.map(\.frame.maxY).max() ?? originY
            )
        case let .table(source, record):
            let table = record.table
            let laidGrid = try grid(
                table,
                source: source,
                originY: originY,
                parameters: parameters
            )
            return NativeBlockLayout(
                kind: try tableMeasurementKind(
                    table,
                    structuralFont: laidGrid.structuralFont
                ),
                fragments: try gridFragments(laidGrid),
                grids: [laidGrid],
                maximumY: laidGrid.frame.maxY
            )
        }
    }

    func tableMeasurementKind(
        _ table: ProjectedTable,
        structuralFont: LayoutFontIdentity
    ) throws -> LayoutBlockMeasurementKind
    {
        let content = table.content
        let rowResult = content.headerRows.count.addingReportingOverflow(
            content.bodyRows.count
        )
        guard !rowResult.overflow
        else
        {
            throw LayoutFailure.unrepresentableBlockMeasurement
        }
        var cellCount = 0
        for row in content.headerRows + content.bodyRows
        {
            let result = cellCount.addingReportingOverflow(row.cells.count)
            guard !result.overflow
            else
            {
                throw LayoutFailure.unrepresentableBlockMeasurement
            }
            cellCount = result.partialValue
        }
        guard let measurement = LayoutTableMeasurement(
            rowCount: rowResult.partialValue,
            cellCount: cellCount,
            structuralFont: structuralFont
        )
        else
        {
            throw LayoutFailure.unrepresentableBlockMeasurement
        }
        return .table(measurement)
    }
}
