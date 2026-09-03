import FundamentalProjection

extension NativeTextKit2Layout
{
    func cells(
        _ measured: [NativeMeasuredCell],
        columns: [LayoutColumnTrack],
        rows: [LayoutRowTrack],
        parameters: LayoutParameters
    ) throws -> (cells: [LayoutCell], lines: [LayoutGridLine])
    {
        var cells: [LayoutCell] = []
        var lines: [LayoutGridLine] = []
        for measuredCell in measured
        {
            let placement = measuredCell.placement
            let x = columns[placement.columnTrack].origin
            let y = rows[placement.rowTrack].origin
            let width = columns[
                placement.columnTrack ..<
                    placement.columnTrack + placement.columnSpan
            ].reduce(0)
            {
                $0 + $1.extent
            } + parameters.columnSpacing
                * Double(placement.columnSpan - 1)
            let height = rows[
                placement.rowTrack ..<
                    placement.rowTrack + placement.rowSpan
            ].reduce(0)
            {
                $0 + $1.extent
            } + parameters.rowSpacing
                * Double(placement.rowSpan - 1)
            let frame = try rectangle(
                x: x,
                y: y,
                width: width,
                height: height
            )
            let resolved = resolvedAlignment(
                placement,
                columns: columns
            )
            let cell = LayoutCell(
                scope: placement.scope,
                sourceRow: placement.sourceRow,
                sourceCell: placement.sourceCell,
                rowTrack: placement.rowTrack,
                columnTrack: placement.columnTrack,
                rowSpan: placement.rowSpan,
                columnSpan: placement.columnSpan,
                projectedAlignment: placement.alignment,
                resolvedAlignment: resolved,
                frame: frame
            )
            cells.append(cell)
            for line in measuredCell.lines
            {
                let contentWidth = width
                    - parameters.cellPadding * 2
                let alignmentOffset = alignmentOffset(
                    resolved,
                    contentWidth: contentWidth,
                    lineWidth: line.frame.size.width
                )
                let translated = try translated(
                    line,
                    dx: x + parameters.cellPadding
                        + alignmentOffset - line.frame.minX,
                    dy: y + parameters.cellPadding
                )
                lines.append(LayoutGridLine(
                    scope: placement.scope,
                    sourceRow: placement.sourceRow,
                    sourceCell: placement.sourceCell,
                    frame: try residencyFrame(
                        translated,
                        x: x,
                        width: width
                    ),
                    line: translated
                ))
            }
        }
        return (cells, lines)
    }

    func resolvedAlignment(
        _ placement: NativeGridPlacement,
        columns: [LayoutColumnTrack]
    ) -> ProjectedTableColumnAlignment
    {
        let selected = placement.alignment == .unspecified
            ? columns[placement.columnTrack].alignment
            : placement.alignment
        return selected == .unspecified ? .leading : selected
    }

    func alignmentOffset(
        _ alignment: ProjectedTableColumnAlignment,
        contentWidth: Double,
        lineWidth: Double
    ) -> Double
    {
        let available = max(0, contentWidth - lineWidth)
        switch alignment
        {
        case .leading, .unspecified:
            return 0
        case .center:
            return available * 0.5
        case .trailing:
            return available
        }
    }
}
