@MainActor
final class DocumentSession
{
    private var currentState: DocumentSessionState

    init(state: DocumentSessionState)
    {
        currentState = state
    }

    var state: DocumentSessionState
    {
        currentState
    }

    var observation: DocumentObservation
    {
        DocumentObservation(snapshot: currentState.snapshot)
    }

    @discardableResult
    func submit(
        _ command: DocumentSessionCommand
    ) -> DocumentSessionTransition
    {
        let result = DocumentSessionTransition(command, in: currentState)
        if case let .applied(successor) = result
        {
            currentState = successor
        }
        return result
    }
}
