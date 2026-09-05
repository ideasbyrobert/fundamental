enum DocumentSessionCommand: Equatable, Sendable
{
    case edit(DocumentObservation, CanonicalDocumentEdit)
    case select(DocumentObservation, DocumentSelection)

    var observation: DocumentObservation
    {
        switch self
        {
        case let .edit(observation, _), let .select(observation, _):
            observation
        }
    }
}
