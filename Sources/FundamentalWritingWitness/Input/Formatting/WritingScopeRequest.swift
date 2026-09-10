import FundamentalDocument

struct WritingScopeRequest: Equatable, Sendable
{
    let observation: DocumentObservation
    let range: DocumentRange
    let selection: WritingScopeSelection

    init?(kind: WritingScopeKind, in projection: WritingProjection)
    {
        guard let selected = WritingSelectedAttributes(projection)
        else
        {
            return nil
        }
        selection = WritingScopeSelection(kind: kind, in: selected)
        observation = projection.observation
        range = projection.snapshot.selection.range
    }

    func setting(_ value: String) -> DocumentSessionCommand?
    {
        selection.kind.setting(value).map { command($0) }
    }

    func removing() -> DocumentSessionCommand
    {
        command(selection.kind.removal)
    }

    private func command(_ assignment: SemanticRunScopeAssignment)
        -> DocumentSessionCommand
    {
        if range.start == range.end
        {
            return .typingScope(observation, assignment)
        }
        return .scope(observation,
            SemanticRunScopeChange(range: range, assignment: assignment))
    }
}
