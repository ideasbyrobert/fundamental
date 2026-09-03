package struct RasterTableCellGeometry: Equatable, Sendable
{
    package let sourceRow: Int
    package let sourceCell: Int
    package let rowTrack: Int
    package let columnTrack: Int
    package let rowSpan: Int
    package let columnSpan: Int
    package let projectedAlignment: RasterTableAlignment
    package let resolvedAlignment: RasterTableAlignment
}
