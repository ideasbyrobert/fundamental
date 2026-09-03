package struct RasterInteractionRegion: Equatable, Sendable
{
    package let residentID: RasterResidentID
    package let residence: RasterResidence
    package let role: RasterInteractionRole
    package let frame: RasterRectangle
    package let content: RasterInteractionContent
}
