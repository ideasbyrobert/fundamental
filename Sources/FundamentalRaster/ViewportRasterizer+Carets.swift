import FundamentalViewport

extension ViewportRasterizer
{
    static func caretSites(
        _ line: ResidentLayoutLine
    ) -> [RasterCaretSite]?
    {
        let count = 1 + line.remainingCaretStops.count
        var sites: [RasterCaretSite] = []
        sites.reserveCapacity(count)
        for index in 0 ..< count
        {
            let stop = index == 0
                ? line.firstCaretStop
                : line.remainingCaretStops[index - 1]
            guard let position = RasterPoint(
                x: stop.position.x,
                y: stop.position.y
            )
            else
            {
                return nil
            }
            let point: RasterTextPoint
            switch stop.sourcePoint
            {
            case let .block(blockID, offset):
                point = .block(
                    blockID: blockID,
                    utf16Offset: offset
                )
            case let .caption(blockID, offset):
                point = .caption(
                    blockID: blockID,
                    utf16Offset: offset
                )
            case let .cell(blockID, row, cell, offset):
                point = .cell(
                    blockID: blockID,
                    row: row,
                    cell: cell,
                    utf16Offset: offset
                )
            }
            sites.append(RasterCaretSite(
                utf16Offset: stop.utf16Offset,
                position: position,
                sourcePoint: point
            ))
        }
        return sites
    }
}
