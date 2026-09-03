package struct PresentationSourceSlice: Equatable, Sendable
{
    package let source: PresentationTextSource
    package let scope: PresentationRunScope
    package let range: Range<Int>
    package let text: String
}
