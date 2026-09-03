package struct DocumentSnapshot: Equatable, Sendable
{
    package let generation: SnapshotGeneration
    package let document: CanonicalDocument

    init(
        generation: SnapshotGeneration,
        document: CanonicalDocument
    )
    {
        self.generation = generation
        self.document = document
    }
}
