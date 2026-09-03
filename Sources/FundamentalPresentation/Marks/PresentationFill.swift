package struct PresentationFill: Equatable, Sendable
{
    package let residentID: PresentationResidentID
    package let role: PresentationFillRole
    package let logicalBounds: PresentationRectangle
    package let pixelBounds: PresentationPixelBounds
    package let color: PresentationColor
    package let sourceSlices: [PresentationSourceSlice]
}
