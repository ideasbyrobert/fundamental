extension NativeTextKit2Layout
{
    func gridRules(
        _ grid: LayoutGrid
    ) throws -> [(
        frame: LayoutRectangle,
        owner: LayoutGridRuleOwner
    )]
    {
        let horizontals = try horizontalGridRules(grid)
        let verticals = try verticalGridRules(grid)
        var rules = horizontals
        for vertical in verticals
        {
            rules += try subtract(horizontals, from: vertical)
        }
        return rules
    }

    private func horizontalGridRules(
        _ grid: LayoutGrid
    ) throws -> [(
        frame: LayoutRectangle,
        owner: LayoutGridRuleOwner
    )]
    {
        let thickness = min(1, grid.frame.size.height / 2)
        var rules: [(LayoutRectangle, LayoutGridRuleOwner)] = [
            (
                try rectangle(
                    x: grid.frame.minX,
                    y: grid.frame.minY,
                    width: grid.frame.size.width,
                    height: thickness
                ),
                .table
            ),
            (
                try rectangle(
                    x: grid.frame.minX,
                    y: grid.frame.maxY - thickness,
                    width: grid.frame.size.width,
                    height: thickness
                ),
                .table
            )
        ]
        let contentY = grid.rowTracks.first?.origin
            ?? grid.captionLines.map(\.frame.maxY).max()
            ?? grid.frame.minY
        if contentY > grid.frame.minY,
           contentY < grid.frame.maxY
        {
            let owner: LayoutGridRuleOwner
            if let row = grid.rowTracks.first
            {
                owner = .row(row.index)
            }
            else
            {
                owner = .table
            }
            rules.append((
                try rectangle(
                    x: grid.frame.minX,
                    y: contentY,
                    width: grid.frame.size.width,
                    height: min(1, grid.frame.maxY - contentY)
                ),
                owner
            ))
        }
        for row in grid.rowTracks.dropFirst()
        {
            if grid.columnTracks.isEmpty
            {
                rules.append((
                    try rectangle(
                        x: grid.frame.minX,
                        y: row.origin,
                        width: grid.frame.size.width,
                        height: min(1, row.extent)
                    ),
                    .row(row.index)
                ))
                continue
            }
            for column in grid.columnTracks
                where !Self.spansRowBoundary(
                    row.index,
                    column: column.index,
                    cells: grid.cells
                )
            {
                rules.append((
                    try rectangle(
                        x: grid.frame.minX + column.origin,
                        y: row.origin,
                        width: column.extent,
                        height: min(1, row.extent)
                    ),
                    .row(row.index)
                ))
            }
        }
        return rules
    }

    private func verticalGridRules(
        _ grid: LayoutGrid
    ) throws -> [(
        frame: LayoutRectangle,
        owner: LayoutGridRuleOwner
    )]
    {
        let thickness = min(1, grid.frame.size.width / 2)
        var rules: [(LayoutRectangle, LayoutGridRuleOwner)] = [
            (
                try rectangle(
                    x: grid.frame.minX,
                    y: grid.frame.minY,
                    width: thickness,
                    height: grid.frame.size.height
                ),
                .table
            ),
            (
                try rectangle(
                    x: grid.frame.maxX - thickness,
                    y: grid.frame.minY,
                    width: thickness,
                    height: grid.frame.size.height
                ),
                .table
            )
        ]
        for column in grid.columnTracks.dropFirst()
        {
            if grid.rowTracks.isEmpty
            {
                let minimumY = grid.captionLines.map(\.frame.maxY).max()
                    ?? grid.frame.minY
                rules.append((
                    try rectangle(
                        x: grid.frame.minX + column.origin,
                        y: minimumY,
                        width: min(1, column.extent),
                        height: grid.frame.maxY - minimumY
                    ),
                    .column(column.index)
                ))
                continue
            }
            for row in grid.rowTracks where !Self.spansColumnBoundary(
                column.index,
                row: row.index,
                cells: grid.cells
            )
            {
                rules.append((
                    try rectangle(
                        x: grid.frame.minX + column.origin,
                        y: row.origin,
                        width: min(1, column.extent),
                        height: row.extent
                    ),
                    .column(column.index)
                ))
            }
        }
        return rules
    }

    private func subtract(
        _ horizontals: [(
            frame: LayoutRectangle,
            owner: LayoutGridRuleOwner
        )],
        from vertical: (
            frame: LayoutRectangle,
            owner: LayoutGridRuleOwner
        )
    ) throws -> [(
        frame: LayoutRectangle,
        owner: LayoutGridRuleOwner
    )]
    {
        var ranges = [(vertical.frame.minY, vertical.frame.maxY)]
        for horizontal in horizontals
            where horizontal.frame.minX < vertical.frame.maxX
                && vertical.frame.minX < horizontal.frame.maxX
        {
            ranges = ranges.flatMap
            {
                minimum, maximum in
                if horizontal.frame.maxY <= minimum
                    || horizontal.frame.minY >= maximum
                {
                    return [(minimum, maximum)]
                }
                var values: [(Double, Double)] = []
                if horizontal.frame.minY > minimum
                {
                    values.append((minimum, horizontal.frame.minY))
                }
                if horizontal.frame.maxY < maximum
                {
                    values.append((horizontal.frame.maxY, maximum))
                }
                return values
            }
        }
        return try ranges.map
        {
            (
                try rectangle(
                    x: vertical.frame.minX,
                    y: $0.0,
                    width: vertical.frame.size.width,
                    height: $0.1 - $0.0
                ),
                vertical.owner
            )
        }
    }

    private static func spansColumnBoundary(
        _ boundary: Int,
        row: Int,
        cells: [LayoutCell]
    ) -> Bool
    {
        cells.contains
        {
            $0.columnTrack < boundary
                && boundary - $0.columnTrack < $0.columnSpan
                && $0.rowTrack <= row
                && row - $0.rowTrack < $0.rowSpan
        }
    }

    private static func spansRowBoundary(
        _ boundary: Int,
        column: Int,
        cells: [LayoutCell]
    ) -> Bool
    {
        cells.contains
        {
            $0.rowTrack < boundary
                && boundary - $0.rowTrack < $0.rowSpan
                && $0.columnTrack <= column
                && column - $0.columnTrack < $0.columnSpan
        }
    }
}
