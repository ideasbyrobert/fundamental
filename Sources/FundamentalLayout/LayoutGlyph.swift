package struct LayoutGlyph: Equatable, Sendable
{
    package let identifier: UInt32
    package let position: LayoutPoint
    package let advance: LayoutVector
    package let sourceSlices: [LayoutSourceSlice]
}
