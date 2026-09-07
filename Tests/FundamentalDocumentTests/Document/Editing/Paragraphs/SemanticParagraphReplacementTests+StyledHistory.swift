import Testing

@testable import FundamentalDocument

extension SemanticParagraphReplacementTests
{
    @MainActor
    @Test("mixed role replacement is one exactly reversible history step")
    func styledHistory() throws
    {
        let source = try SemanticWritingTestDocument(
            [.title, .bulleted, .numbered], texts: ["A😀B", "CD", "EF"]
        )
        let range = try source.range((2, 1), (0, 1))
        let state = try source.state(range)
        let session = DocumentSession(state: state, initiallySaved: true)
        let edit = try source.replacement((2, 1), (0, 1), text: ["X", "Y"])
        session.submit(.edit(session.observation, .paragraphs(edit)))
        let after = session.document.content
        #expect(session.history.undo.count == 1)
        #expect(SemanticWritingTestDocument.texts(session.document) ==
            ["AX", "YF"])
        #expect(after.blocks.map { CanonicalBlockStyle($0.block) } ==
            [.title, .body])
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .undo
        ))
        #expect(session.document.content == source.document.content)
        #expect(!session.isDirty)
        guard case let .editable(restored) = session.state
        else
        {
            Issue.record("Expected the restored semantic selection")
            return
        }
        #expect(restored.selection.range.start.blockID == range.start.blockID)
        #expect(restored.selection.range.end.blockID == range.end.blockID)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .redo
        ))
        #expect(session.document.content == after)
        #expect(session.isDirty)
    }
}
