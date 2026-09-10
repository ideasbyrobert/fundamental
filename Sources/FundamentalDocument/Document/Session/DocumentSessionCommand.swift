package enum DocumentSessionCommand: Equatable, Sendable
{
    case edit(DocumentObservation, CanonicalDocumentEdit)
    case input(DocumentObservation, DocumentInputTransaction)
    case select(DocumentObservation, DocumentSelection)
    case style(DocumentObservation, SemanticBlockStyleChange)
    case convertCode(DocumentObservation, SemanticCodeConversion)
    case inline(DocumentObservation, SemanticInlineTraitChange)
    case typing(DocumentObservation, SemanticInlineTraitAssignment)
    case scope(DocumentObservation, SemanticRunScopeChange)
    case typingScope(DocumentObservation, SemanticRunScopeAssignment)

    var observation: DocumentObservation
    {
        switch self
        {
        case let .edit(observation, _), let .input(observation, _),
             let .select(observation, _),
             let .style(observation, _), let .convertCode(observation, _),
             let .inline(observation, _), let .typing(observation, _),
             let .scope(observation, _), let .typingScope(observation, _):
            observation
        }
    }

    var changesContent: Bool
    {
        switch self
        {
        case .edit, .style, .convertCode, .inline, .scope:
            true
        case let .input(_, transaction):
            transaction.edit != nil
        case .select, .typing, .typingScope:
            false
        }
    }
}
