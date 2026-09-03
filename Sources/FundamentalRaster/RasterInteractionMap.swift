package struct RasterInteractionMap: Equatable, Sendable
{
    package let firstRegion: RasterInteractionRegion
    package let remainingRegions: [RasterInteractionRegion]

    package var regions: [RasterInteractionRegion]
    {
        [firstRegion] + remainingRegions
    }
}
