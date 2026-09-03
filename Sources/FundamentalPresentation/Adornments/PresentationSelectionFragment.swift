package struct PresentationSelectionFragment: Equatable, Sendable
{
    package let residentID: PresentationResidentID
    package let range: Range<Int>
    package let logicalBounds: PresentationRectangle
    package let text: String
    package let sourceSlices: [PresentationSourceSlice]
}
