package struct RasterAppearance: Equatable, Sendable
{
    package let luminosity: RasterLuminosity
    package let contrast: RasterContrast

    package init(
        luminosity: RasterLuminosity,
        contrast: RasterContrast
    )
    {
        self.luminosity = luminosity
        self.contrast = contrast
    }
}
