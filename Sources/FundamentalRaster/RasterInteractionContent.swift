package enum RasterInteractionContent: Equatable, Sendable
{
    case region
    case text(RasterInteractionText)
    case columnTrack(RasterTableColumnGeometry)
    case rowTrack(RasterTableRowGeometry)
    case cell(RasterTableCellGeometry)
}
