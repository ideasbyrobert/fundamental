package struct PresentationRasterLineage: Equatable, Sendable
{
    package let viewport: PresentationViewportLineage
    package let generation: UInt64
    package let specification: PresentationRasterSpecificationIdentity
}
