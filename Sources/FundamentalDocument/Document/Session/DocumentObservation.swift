package struct DocumentObservation: Equatable, Sendable
{
    let documentID: FundamentalDocumentID
    let revision: DocumentRevision
    let generation: SnapshotGeneration

    package init(snapshot: DocumentSnapshot)
    {
        documentID = snapshot.document.documentID
        revision = snapshot.document.revision
        generation = snapshot.generation
    }
}
