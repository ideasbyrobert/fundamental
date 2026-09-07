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
        switch command
        {
        case .select:
            history = current.history
        case .edit, .style:
            guard let recorded = recordedHistory(for: successor)
            else
            {
                return .refused(.historyCapacity)
            }
            history = recorded
        }
        current = DocumentSessionStorage(state: successor, history: history)
        if command.changesContent
        {
            persistence.contentRevision = successor.snapshot.document.revision
        }
        return result
    }
}
