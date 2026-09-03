package struct LayoutGridLine: Equatable, Sendable
{
    package let scope: LayoutTableRowScope
    package let sourceRow: Int
    package let sourceCell: Int
    package let frame: LayoutRectangle
    package let line: LayoutLine
}
