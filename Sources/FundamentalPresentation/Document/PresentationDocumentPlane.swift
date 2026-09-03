package struct PresentationDocumentPlane: Equatable, Sendable
{
    package let documentSize: PresentationSize
    package let logicalBounds: PresentationRectangle
    package let pixelBounds: PresentationPixelBounds
    package let backingScale: Double
    package let appearance: PresentationAppearance
    package let colorSpace: PresentationColorSpaceIdentity
    package let palette: PresentationPalette
}
