extension DocumentSession
{
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
        if command.changesContent
        {
            guard let recorded = recordedHistory(for: successor)
            else
            {
                return .refused(.historyCapacity)
            }
            history = recorded
        }
        else
        {
            history = current.history
        }
        current = DocumentSessionStorage(state: successor, history: history)
        if command.changesContent
        {
            persistence.contentRevision = successor.snapshot.document.revision
        }
        return result
    }
}
