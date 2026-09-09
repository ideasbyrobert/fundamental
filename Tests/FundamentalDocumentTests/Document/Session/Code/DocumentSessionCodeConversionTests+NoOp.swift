import Testing

@testable import FundamentalDocument

extension DocumentSessionCodeConversionTests
{
    @Test("a no-op conversion after undo keeps the redo transaction")
    func noOpPreservesRedo() throws
    {
        let source = try SemanticWritingTestDocument([.body], texts: ["A"])
        let session = DocumentSession(
            state: try source.state(), initiallySaved: true
        )
        let created = try session.submit(.convertCode(
            session.observation,
            SemanticCodeConversion(range: source.range((0, 0), (0, 0)))
        ))
        guard case .applied = created
        else
        {
            Issue.record("Expected a code block before undo")
            return
        }
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .undo
        ))
        guard case let .editable(editable) = session.state
        else
        {
            Issue.record("Expected the restored paragraph")
            return
        }
        let before = session.current
        let conversion = try #require(SemanticCodeConversion(
            range: editable.selection.range, proseStyle: .body
        ))
        #expect(session.submit(.convertCode(
            session.observation, conversion
        )) == .unchanged)
        #expect(session.current == before)
        #expect(session.canRedo)
        #expect(!session.isDirty)
    }
}
