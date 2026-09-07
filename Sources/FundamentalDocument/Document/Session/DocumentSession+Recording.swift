extension DocumentSession
{
    func recordedHistory(
        for successor: DocumentSessionState
    ) -> DocumentHistory?
    {
        guard case let .editable(before) = current.state,
              case let .editable(after) = successor,
              let first = DocumentHistoryCheckpoint(
                  before, contentRevision: persistence.contentRevision
              ),
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
