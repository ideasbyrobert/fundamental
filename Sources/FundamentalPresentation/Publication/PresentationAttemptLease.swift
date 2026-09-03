package struct PresentationAttemptLease: Equatable, Sendable
{
    package let generation: UInt64

    package init(generation: UInt64)
    {
        self.generation = generation
    }
}
