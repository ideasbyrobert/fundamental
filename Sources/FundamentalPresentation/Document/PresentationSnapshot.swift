package enum PresentationSnapshot: Equatable, Sendable
{
    case document(PresentedDocument)
    case caret(PresentedDocument, PresentationCaretAdornment)
    case selection(PresentedDocument, PresentationSelectionAdornment)

    package var presentedDocument: PresentedDocument
    {
        switch self
        {
        case let .document(document):
            document
        case let .caret(document, _):
            document
        case let .selection(document, _):
            document
        }
    }

    package var lineage: PresentationLineage
    {
        presentedDocument.lineage
    }
}
