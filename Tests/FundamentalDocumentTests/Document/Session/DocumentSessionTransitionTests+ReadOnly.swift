import Testing

@testable import FundamentalDocument

extension DocumentSessionTransitionTests
{
    @Test("readable tables and deliberately readable prose refuse commands")
    func readOnly() throws
    {
        let fixture = try SessionTestDocument()
        let content = try #require(SemanticTableContent(
            headerRows: [],
            bodyRows: [],
            columnAlignments: []
        ))
        let block = IdentifiedSemanticBlock(
            blockID: fixture.editable.snapshot.document.content
                .firstBlock.blockID,
            block: .table(.semantic(.regular(RegularSemanticTable(
                content: content
            ))))
        )
        let tableDocument = CanonicalDocument(
            documentID: fixture.editable.snapshot.document.documentID,
            revision: DocumentRevision(8),
            content: try #require(CanonicalDocumentContent(
                firstBlock: block,
                remainingBlocks: []
            ))
        )
        let snapshots = [fixture.editable.snapshot, DocumentSnapshot(
            generation: SnapshotGeneration(3),
            document: tableDocument
        )]
        for snapshot in snapshots
        {
            let observation = DocumentObservation(snapshot: snapshot)
            let commands: [DocumentSessionCommand] = [
                .edit(observation,
                      try SessionTestEdit.insertion.edit(in: fixture)),
                .select(observation, fixture.editable.selection)
            ]
            for command in commands
            {
                #expect(DocumentSessionTransition(
                    command,
                    in: .readable(snapshot)
                ) == .refused(.readOnly))
            }
        }
    }
}
