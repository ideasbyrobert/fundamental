package enum DocumentSessionTransition: Equatable, Sendable
{
    case applied(DocumentSessionState)
    case unchanged
    case refused(DocumentSessionRefusal)

    init(
        _ command: DocumentSessionCommand,
        in state: DocumentSessionState
    )
    {
        guard command.observation == DocumentObservation(
            snapshot: state.snapshot
        )
        else
        {
            self = .refused(.staleObservation)
            return
        }
        guard case let .editable(editable) = state
        else
        {
            self = .refused(.readOnly)
            return
        }
        switch command
        {
        case let .edit(_, edit):
            self = Self.apply(edit, to: editable)
        case let .select(_, selection):
            self = Self.select(selection, in: editable)
        }
    }

    private static func apply(
        _ edit: CanonicalDocumentEdit,
        to source: EditableDocumentSnapshot
    ) -> DocumentSessionTransition
    {
        guard let generation = SnapshotGeneration(
            after: source.snapshot.generation
        )
        else
        {
            return .refused(.generationExhausted)
        }
        guard let applied = AppliedCanonicalDocumentEdit(
            edit,
            in: source.snapshot.document
        ),
              let editable = EditableDocumentSnapshot(
                  snapshot: DocumentSnapshot(
                      generation: generation,
                      document: applied.document
                  ),
                  selection: .caret(at: applied.caret.point)
              )
        else
        {
            return .refused(.invalidCommand)
        }
        return .applied(.editable(editable))
    }

    private static func select(
        _ selection: DocumentSelection,
        in source: EditableDocumentSnapshot
    ) -> DocumentSessionTransition
    {
        guard ResolvedDocumentRange(
            selection.range,
            in: source.snapshot.document
        ) != nil
        else
        {
            return .refused(.invalidCommand)
        }
        if selection == source.selection
        {
            return .unchanged
        }
        guard let generation = SnapshotGeneration(
            after: source.snapshot.generation
        )
        else
        {
            return .refused(.generationExhausted)
        }
        guard let editable = EditableDocumentSnapshot(
            snapshot: DocumentSnapshot(
                generation: generation,
                document: source.snapshot.document
            ),
            selection: selection
        )
        else
        {
            return .refused(.invalidCommand)
        }
        return .applied(.editable(editable))
    }
}
