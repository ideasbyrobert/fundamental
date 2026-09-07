extension DocumentSession
{
    @discardableResult
    package func submit(
        _ command: DocumentHistoryCommand
    ) -> DocumentSessionTransition
    {
        guard command.observation == observation
        else
        {
            return .refused(.staleObservation)
        }
        guard case .editable = current.state
        else
        {
            return .refused(.readOnly)
        }
        let checkpoint: DocumentHistoryCheckpoint
        switch command.direction
        {
        case .undo:
            guard let transaction = current.history.undo.last
            else
            {
                return .refused(.historyUnavailable)
            }
            checkpoint = transaction.before
        case .redo:
            guard let transaction = current.history.redo.last
            else
            {
                return .refused(.historyUnavailable)
            }
            checkpoint = transaction.after
        }
        guard current.state.snapshot.generation.value < UInt64.max
        else
        {
            return .refused(.generationExhausted)
        }
        guard let restored = RestoredDocumentHistoryCheckpoint(
            checkpoint,
            in: current.state.snapshot
        ),
              let history = DocumentHistory(
                  moving: command.direction,
                  in: current.history
              )
        else
        {
            return .refused(.invalidCommand)
        }
        let successor = DocumentSessionState.editable(restored.snapshot)
        current = DocumentSessionStorage(state: successor, history: history)
        persistence.contentRevision = checkpoint.contentRevision
        return .applied(successor)
    }
}
