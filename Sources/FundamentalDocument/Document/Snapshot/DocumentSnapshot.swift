struct DocumentSnapshot: Equatable, Sendable
{
    let generation: SnapshotGeneration
    let document: CanonicalDocument

    init(
        generation: SnapshotGeneration,
        document: CanonicalDocument
    )
    {
        self.generation = generation
        self.document = document
    }
}
