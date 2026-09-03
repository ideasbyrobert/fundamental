package struct PresentationAppearance: Equatable, Sendable
{
    package let luminosity: PresentationLuminosity
    package let contrast: PresentationContrast

    package init(
        luminosity: PresentationLuminosity,
        contrast: PresentationContrast
    )
    {
        self.luminosity = luminosity
        self.contrast = contrast
    }
}
