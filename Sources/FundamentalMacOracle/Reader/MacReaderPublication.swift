import FundamentalPresentation

@MainActor
struct MacReaderPublication
{
    let snapshot: PresentationSnapshot
    let execution: MacAdmittedRasterExecution

    init?(
        snapshot: PresentationSnapshot,
        execution: MacAdmittedRasterExecution
    )
    {
        guard snapshot.lineage == execution.lineage,
              snapshot.presentedDocument.sharesStorage(
                  with: execution.documentExecution.source
              ),
              Self.formsMatch(snapshot, execution: execution)
        else
        {
            return nil
        }
        self.snapshot = snapshot
        self.execution = execution
    }

    private static func formsMatch(
        _ snapshot: PresentationSnapshot,
        execution: MacAdmittedRasterExecution
    ) -> Bool
    {
        switch (snapshot, execution)
        {
        case (.document, .document):
            return true
        case let (.caret(_, source), .caret(_, _, admitted)):
            return source == admitted.source
        case let (
            .selection(_, source),
            .selection(_, _, admitted)
        ):
            return source == admitted.source
        default:
            return false
        }
    }
}
