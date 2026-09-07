@MainActor
package final class DocumentSession
{
    var current: DocumentSessionStorage
    var persistence: DocumentSessionPersistence

    package convenience init(
        state: DocumentSessionState,
        initiallySaved: Bool = false
    )
    {
        self.init(
            state: state,
            historyLimits: DocumentHistoryLimits(),
            initiallySaved: initiallySaved
        )
    }

    init(
        state: DocumentSessionState,
        historyLimits: DocumentHistoryLimits,
        initiallySaved: Bool = false
    )
    {
        current = DocumentSessionStorage(
            state: state,
            history: DocumentHistory(limits: historyLimits)
        )
        persistence = DocumentSessionPersistence(
            contentRevision: state.snapshot.document.revision,
            initiallySaved: initiallySaved
        )
    }

    package var state: DocumentSessionState
    {
        current.state
    }

    package var document: CanonicalDocument
    {
        current.state.snapshot.document
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
}
