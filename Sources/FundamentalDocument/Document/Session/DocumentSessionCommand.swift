package enum DocumentSessionCommand: Equatable, Sendable
{
    case edit(DocumentObservation, CanonicalDocumentEdit)
    case select(DocumentObservation, DocumentSelection)
    case style(DocumentObservation, SemanticBlockStyleChange)
    case convertCode(DocumentObservation, SemanticCodeConversion)
    case inline(DocumentObservation, SemanticInlineTraitChange)

    var observation: DocumentObservation
    {
        switch self
        {
        case let .edit(observation, _), let .select(observation, _),
             let .style(observation, _), let .convertCode(observation, _),
             let .inline(observation, _):
            observation
        }
    }

    var changesContent: Bool
    {
        switch self
        {
        case .edit, .style, .convertCode, .inline:
            true
        case .select:
            false
        }
    }
}
