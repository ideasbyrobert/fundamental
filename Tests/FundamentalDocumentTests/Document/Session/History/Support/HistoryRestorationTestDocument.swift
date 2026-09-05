import Testing

@testable import FundamentalDocument

struct HistoryRestorationTestDocument
{
    let checkpoint: DocumentHistoryCheckpoint
    let current: DocumentSnapshot

    init() throws
    {
        let fixture = try SessionTestDocument(texts: ["Ae\u{301}B"])
        let language = try #require(SemanticLanguageIdentifier("fr"))
        let insertion = try #require(SemanticInsertion(
            text: "😀",
            attributes: .scoped(traits: [.strong], scopes: .language(language))
        ))
        let edit = CanonicalDocumentEdit.text(.insertion(SemanticTextInsertion(
            point: try fixture.point(1),
            insertion: insertion
        )))
        let applied = try #require(AppliedCanonicalDocumentEdit(
            edit,
            in: fixture.editable.snapshot.document
        ))
        let document = applied.document
        let start = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: document.content.firstBlock.blockID,
            utf16Offset: try #require(DocumentUTF16Offset(6))
        )
        let end = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: document.content.firstBlock.blockID,
            utf16Offset: try #require(DocumentUTF16Offset(1))
        )
        let range = try #require(DocumentRange(start: start, end: end))
        let editable = try #require(EditableDocumentSnapshot(
            snapshot: DocumentSnapshot(
                generation: SnapshotGeneration(4),
                document: document
            ),
            selection: DocumentSelection(range: range)
        ))
        checkpoint = try #require(DocumentHistoryCheckpoint(editable))
        current = try SessionTestDocument(
            texts: ["gone"],
            revision: 90,
            generation: 100
        ).editable.snapshot
    }
}
