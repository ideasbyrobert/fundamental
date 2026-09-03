package struct LayoutSpecificationIdentity:
    Equatable,
    Hashable,
    Sendable
{
    package let version: UInt64
    package let parameters: LayoutParameters
    package let resolvedFonts: [LayoutFontIdentity]

    init(
        parameters: LayoutParameters,
        resolvedFonts: [LayoutFontIdentity]
    )
    {
        version = 1
        self.parameters = parameters
        self.resolvedFonts = resolvedFonts
    }
}
