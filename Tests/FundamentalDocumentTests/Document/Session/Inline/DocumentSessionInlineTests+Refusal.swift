import Testing

@testable import FundamentalDocument

extension DocumentSessionInlineTests
{
    @Test("stale observations and split source characters refuse atomically")
    func invalidSelection() throws
    {
        let source = try SemanticWritingTestDocument(
            [.body], texts: ["😀e\u{301}\r\nB"]
        )
        let session = DocumentSession(
            state: try source.state(), initiallySaved: true
        )
        let stale = session.observation
        session.submit(.select(session.observation, DocumentSelection(
            range: try source.range((0, 2), (0, 2))
        )))
        let before = session.current
        #expect(session.submit(.inline(stale, SemanticInlineTraitChange(
            range: try source.range((0, 0), (0, 2)),
            trait: .strong, enabled: true
        ))) == .refused(.staleObservation))
        for offset in [1, 3, 5, 8]
        {
            #expect(session.submit(.inline(session.observation,
                SemanticInlineTraitChange(
                    range: try source.range((0, offset), (0, offset)),
                    trait: .strong, enabled: true
                )
            )) == .refused(.invalidCommand))
            #expect(session.current == before)
            #expect(!session.isDirty)
        }
    }

    @Test("intervening tables and readable sessions cannot publish traits")
    func tablesAndReadOnly() throws
    {
        for table in try BlockRecordTestValue.tables()
        {
            let source = try SemanticWritingTestDocument(blocks: [
                .paragraph(SemanticParagraph(runs: [SemanticRun(text: "A")])),
                .table(table),
                .paragraph(SemanticParagraph(runs: [SemanticRun(text: "B")]))
            ])
            let change = SemanticInlineTraitChange(
                range: try source.range((0, 0), (2, 1)),
                trait: .strong, enabled: true
            )
            #expect(AppliedSemanticInlineTraitChange(
                change, in: source.document
            ) == nil)
            let session = DocumentSession(state: .readable(DocumentSnapshot(
                generation: SnapshotGeneration(0), document: source.document
            )), initiallySaved: true)
            let before = session.current
            #expect(session.submit(.inline(session.observation, change)) ==
                .refused(.readOnly))
            #expect(session.current == before)
            #expect(!session.isDirty)
        }
    }
}
