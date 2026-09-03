package struct PresentationGlyph: Equatable, Sendable
{
    package let identifier: UInt32
    package let position: PresentationPoint
    package let advance: PresentationVector
    package let sourceSlices: [PresentationSourceSlice]
}
