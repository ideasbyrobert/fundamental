package struct RasterSnapshot: Equatable, Sendable
{
    package let lineage: RasterLineage
    package let documentSize: RasterSize
    package let sourceAnchor: RasterSourceAnchor
    package let marks: [RasterMark]
    package let interactionMap: RasterInteractionMap
}
