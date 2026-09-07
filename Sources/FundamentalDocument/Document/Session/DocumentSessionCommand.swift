package enum DocumentSessionCommand: Equatable, Sendable
{
    case edit(DocumentObservation, CanonicalDocumentEdit)
    case select(DocumentObservation, DocumentSelection)
    case style(DocumentObservation, SemanticBlockStyleChange)

    var observation: DocumentObservation
    {
        switch self
        {
        case let .edit(observation, _), let .select(observation, _),
             let .style(observation, _):
            observation
        }
    }

    var changesContent: Bool
    {
        switch self
        {
        case .edit, .style:
            true
        case .select:
            false
        }
    }
}
