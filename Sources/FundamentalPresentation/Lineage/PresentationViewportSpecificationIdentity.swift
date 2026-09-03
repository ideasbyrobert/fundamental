package struct PresentationViewportSpecificationIdentity:
    Equatable,
    Sendable
{
    package let visibleBounds: PresentationRectangle
    package let precedingOverscanExtent: Double
    package let followingOverscanExtent: Double
    package let maximumResidentCount: Int
}
