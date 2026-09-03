import CoreText
import FundamentalProjection

extension NativeTextKit2Layout
{
    func grid(
        _ table: ProjectedTable,
        source: ProjectedBlockSource,
        originY: Double,
        parameters: LayoutParameters
    ) throws -> LayoutGrid
    {
        let content = table.content
        let placements = try gridPlacements(content)
        let structuralFont = try fontIdentity(
            try tableFont(.body) as CTFont
        )
        let dimensions = try gridDimensions(
            content,
            placements: placements
        )
        let caption = try captionLines(
            table,
            source: source,
            width: parameters.width,
            originY: originY
        )
        let captionBottom = caption.map(\.frame.maxY).max() ?? originY
        let contentY = captionBottom
            + (caption.isEmpty || dimensions.rows == 0
                ? 0
                : parameters.rowSpacing)
        let columnExtent = try columnExtent(
            count: dimensions.columns,
            parameters: parameters
        )
        let columns = try columnTracks(
            content,
            count: dimensions.columns,
            extent: columnExtent,
            spacing: parameters.columnSpacing
        )
        let measured = try measuredCells(
            placements,
            blockID: source.blockID,
            columnExtent: columnExtent,
            parameters: parameters
        )
        let heights = try rowHeights(
            measured,
            count: dimensions.rows,
            structuralLineHeight:
                structuralFont.metrics.ascent
                    + structuralFont.metrics.descent
                    + structuralFont.metrics.leading,
            parameters: parameters
        )
        let rows = try rowTracks(
            count: dimensions.rows,
            headerCount: content.headerRows.count,
            heights: heights,
            originY: contentY,
            spacing: parameters.rowSpacing
        )
        let laidCells = try cells(
            measured,
            columns: columns,
            rows: rows,
            parameters: parameters
        )
        var rowBottom = rows.last.map
        {
            $0.origin + $0.extent
        } ?? contentY
        if rows.isEmpty
        {
            rowBottom += structuralFont.metrics.ascent
                + structuralFont.metrics.descent
                + structuralFont.metrics.leading
        }
        let columnWidth = columns.last.map
        {
            $0.origin + $0.extent
        } ?? parameters.width
        let frame = try rectangle(
            x: 0,
            y: originY,
            width: max(parameters.width, columnWidth),
            height: max(captionBottom, rowBottom) - originY
        )
        return LayoutGrid(
            source: source,
            frame: frame,
            structuralFont: structuralFont,
            columnTracks: columns,
            rowTracks: rows,
            cells: laidCells.cells,
            captionLines: caption,
            cellLines: laidCells.lines
        )
    }

    func captionLines(
        _ table: ProjectedTable,
        source: ProjectedBlockSource,
        width: Double,
        originY: Double
    ) throws -> [LayoutLine]
    {
        switch table
        {
        case .regular:
            []
        case let .captioned(_, caption):
            try textLines(
                runs: caption.runs,
                width: width,
                originX: 0,
                originY: originY,
                font: try captionFont(),
                pointContext: .caption(source.blockID)
            )
        }
    }
}
