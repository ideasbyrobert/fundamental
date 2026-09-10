import Testing

@testable import FundamentalDocument

extension DocumentSessionScopeTests
{
    @Test("stale and split-character scope requests refuse atomically")
    func invalidSelection() throws
    {
        let source = try SemanticWritingTestDocument(
            [.body], texts: ["😀e\u{301}\r\nB"]
        )
        let session = DocumentSession(state: try source.state(),
                                      initiallySaved: true)
        let stale = session.observation
        session.submit(.select(session.observation, DocumentSelection(
            range: try source.range((0, 2), (0, 2))
        )))
        let before = session.current
        let assignment = try ScopeTestValue.assignments()[0]
        #expect(session.submit(.scope(stale, SemanticRunScopeChange(
            range: try source.range((0, 0), (0, 2)), assignment: assignment
        ))) == .refused(.staleObservation))
        for offset in [1, 3, 5, 8]
        {
            #expect(session.submit(.scope(session.observation,
                SemanticRunScopeChange(
                    range: try source.range((0, offset), (0, offset)),
                    assignment: assignment
                )
            )) == .refused(.invalidCommand))
            #expect(session.current == before && !session.isDirty)
        }
    }

    @Test("tables and read-only sessions cannot publish scope changes")
    func tablesAndReadOnly() throws
    {
        for table in try BlockRecordTestValue.tables()
        {
            let source = try SemanticWritingTestDocument(blocks: [
                .paragraph(SemanticParagraph(runs: [SemanticRun(text: "A")])),
                .table(table),
                .paragraph(SemanticParagraph(runs: [SemanticRun(text: "B")]))
            ])
            let change = SemanticRunScopeChange(
                range: try source.range((0, 0), (2, 1)),
                assignment: try ScopeTestValue.assignments()[0]
            )
            #expect(AppliedSemanticRunScopeChange(
                change, in: source.document
            ) == nil)
            let snapshot = DocumentSnapshot(
                generation: SnapshotGeneration(0), document: source.document
            )
            #expect(try EditableDocumentSnapshot(snapshot: snapshot,
                selection: .caret(at: source.point(0, 0))) == nil)
            let readable = DocumentSession(state: .readable(snapshot))
            let unchanged = readable.current
            #expect(readable.submit(.scope(readable.observation, change)) ==
                .refused(.readOnly))
            #expect(readable.current == unchanged)
        }
    }
}
