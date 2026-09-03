package struct PresentationRequest: Equatable, Sendable
{
    package let expectedRasterLineage: PresentationRasterLineage
    package let generation: UInt64
    package let specification: PresentationSpecificationIdentity
    package let intent: PresentationIntent

    package init(
        expectedRasterLineage: PresentationRasterLineage,
        generation: UInt64,
        specification: PresentationSpecificationIdentity,
        intent: PresentationIntent
    )
    {
        self.expectedRasterLineage = expectedRasterLineage
        self.generation = generation
        self.specification = specification
        self.intent = intent
    }
}
