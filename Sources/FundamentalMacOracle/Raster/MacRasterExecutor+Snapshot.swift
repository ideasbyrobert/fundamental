import FundamentalPresentation

extension MacRasterExecutor
{
    func admit(
        _ snapshot: PresentationSnapshot,
        document: MacAdmittedDocumentExecution
    ) -> MacAdmittedRasterExecution?
    {
        let lineage = snapshot.lineage
        switch snapshot
        {
        case .document:
            return .document(
                lineage: lineage,
                document: document
            )
        case let .caret(_, caret):
            guard let admitted = admit(
                caret,
                colorSpace: document.colorSpace
            )
            else
            {
                return nil
            }
            return .caret(
                lineage: lineage,
                document: document,
                caret: admitted
            )
        case let .selection(_, selection):
            guard let admitted = admit(
                selection,
                colorSpace: document.colorSpace
            )
            else
            {
                return nil
            }
            return .selection(
                lineage: lineage,
                document: document,
                selection: admitted
            )
        }
    }
}
