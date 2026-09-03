import FundamentalPresentation

@MainActor
enum MacAdmittedRasterExecution
{
    case document(
        lineage: PresentationLineage,
        document: MacAdmittedDocumentExecution
    )
    case caret(
        lineage: PresentationLineage,
        document: MacAdmittedDocumentExecution,
        caret: MacAdmittedCaretExecution
    )
    case selection(
        lineage: PresentationLineage,
        document: MacAdmittedDocumentExecution,
        selection: MacAdmittedSelectionExecution
    )

    var lineage: PresentationLineage
    {
        switch self
        {
        case let .document(lineage, _),
             let .caret(lineage, _, _),
             let .selection(lineage, _, _):
            lineage
        }
    }

    var generation: UInt64
    {
        lineage.generation
    }

    var documentExecution: MacAdmittedDocumentExecution
    {
        switch self
        {
        case let .document(_, document),
             let .caret(_, document, _),
             let .selection(_, document, _):
            document
        }
    }
}
