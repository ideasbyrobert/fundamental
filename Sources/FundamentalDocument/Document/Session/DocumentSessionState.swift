enum DocumentSessionState: Equatable, Sendable
{
    case readable(DocumentSnapshot)
    case editable(EditableDocumentSnapshot)

    var snapshot: DocumentSnapshot
    {
        switch self
        {
        case let .readable(snapshot):
            snapshot
        case let .editable(snapshot):
            snapshot.snapshot
        }
    }
}
