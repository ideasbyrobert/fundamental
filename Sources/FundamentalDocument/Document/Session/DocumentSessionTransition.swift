package enum DocumentSessionTransition: Equatable, Sendable
{
    case applied(DocumentSessionState)
    case unchanged
    case refused(DocumentSessionRefusal)

    package init(
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
        case let .style(_, change):
            self = Self.style(change, in: editable)
        case let .convertCode(_, conversion):
            self = Self.convertCode(conversion, in: editable)
        case let .inline(_, change):
            self = Self.inline(change, in: editable)
        case let .typing(_, assignment):
            self = Self.typing(assignment, in: editable)
        }
    }

}
