import Testing

@testable import FundamentalLayout
@testable import FundamentalRaster

extension RasterFixture
{
    static func expectedCaretSite(
        _ stop: LayoutCaretStop
    ) throws -> RasterCaretSite
    {
        let sourcePoint: RasterTextPoint
        switch stop.sourcePoint
        {
        case let .block(blockID, offset):
            sourcePoint = .block(
                blockID: blockID,
                utf16Offset: offset
            )
        case let .caption(blockID, offset):
            sourcePoint = .caption(
                blockID: blockID,
                utf16Offset: offset
            )
        case let .cell(blockID, row, cell, offset):
            sourcePoint = .cell(
                blockID: blockID,
                row: row,
                cell: cell,
                utf16Offset: offset
            )
        }
        let position = try #require(RasterPoint(
            x: stop.position.x,
            y: stop.position.y
        ))
        return RasterCaretSite(
            utf16Offset: stop.utf16Offset,
            position: position,
            sourcePoint: sourcePoint
        )
    }
}
