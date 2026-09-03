package struct PresentationLayoutSpecificationIdentity:
    Equatable,
    Sendable
{
    package let version: UInt64
    package let parameters: PresentationLayoutParameters
    package let resolvedFonts: [PresentationFontIdentity]
}
