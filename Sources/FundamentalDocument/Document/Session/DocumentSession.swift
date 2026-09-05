@MainActor
package final class DocumentSession
{
    private var current: DocumentSessionStorage

    package convenience init(state: DocumentSessionState)
    {
        self.init(state: state, historyLimits: DocumentHistoryLimits())
    }

    init(
        state: DocumentSessionState,
        historyLimits: DocumentHistoryLimits
    )
    {
        current = DocumentSessionStorage(
            state: state,
            history: DocumentHistory(limits: historyLimits)
        )
    }

    package var state: DocumentSessionState
    {
        current.state
    }

    var history: DocumentHistory
    {
        current.history
    }

    package var canUndo: Bool
    {
        !current.history.undo.isEmpty
    }

    package var canRedo: Bool
    {
        !current.history.redo.isEmpty
    }

    var observation: DocumentObservation
    {
        DocumentObservation(snapshot: current.state.snapshot)
    }

    @discardableResult
    package func submit(
        _ command: DocumentSessionCommand
    ) -> DocumentSessionTransition
    {
        let result = DocumentSessionTransition(command, in: current.state)
        guard case let .applied(successor) = result
        else
        {
            return result
        }
        let history: DocumentHistory
        switch command
        {
        case .select:
            history = current.history
        case .edit:
            guard let recorded = recordedHistory(for: successor)
            else
            {
                return .refused(.historyCapacity)
            }
            history = recorded
        }
        current = DocumentSessionStorage(state: successor, history: history)
        return result
    }

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
        return .applied(successor)
    }

    private func recordedHistory(
        for successor: DocumentSessionState
    ) -> DocumentHistory?
    {
        guard case let .editable(before) = current.state,
              case let .editable(after) = successor,
              let first = DocumentHistoryCheckpoint(before),
              let last = DocumentHistoryCheckpoint(after),
              let transaction = DocumentHistoryTransaction(
                  before: first,
                  after: last
              )
        else
        {
            return nil
        }
        return DocumentHistory(recording: transaction, in: current.history)
    }
}
