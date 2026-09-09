import Testing

@testable import FundamentalDocument

extension SemanticParagraphReplacementTests
{
    @MainActor
    @Test(arguments: ["", "X", "X\r\n\te\u{301}😀"])
    func mixedCodeReplacementRestoresDirectedSelection(text: String) throws
    {
        let source = try SemanticWritingTestDocument(
            [.numbered, .monostyled, .title],
            texts: ["A😀B", "\tC\r\nD\r", "EF"]
        )
        let range = try source.range((2, 1), (0, 1))
        let state = try source.state(range)
        let session = DocumentSession(state: state, initiallySaved: true)
        let edit = try source.replacement((2, 1), (0, 1), text: [text])
        let command = DocumentSessionCommand.edit(
            session.observation, .paragraphs(edit)
        )
        guard case .applied = session.submit(command)
        else
        {
            Issue.record("Expected one mixed code replacement")
            return
        }
        let after = session.document.content
        #expect(session.history.undo.count == 1)
        #expect(SemanticWritingTestDocument.texts(session.document)[0].utf16
            .elementsEqual(("A" + text + "F").utf16))
        let saved = DocumentSessionStorage(
            state: session.state, history: session.history
        )
        #expect(session.submit(command) == .refused(.staleObservation))
        #expect(DocumentSessionStorage(state: session.state,
            history: session.history) == saved)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .undo
        ))
        #expect(session.document.content == source.document.content)
        #expect(!session.isDirty)
        guard case let .editable(restored) = session.state
        else
        {
            Issue.record("Expected the restored directed selection")
            return
        }
        #expect(restored.selection.range.start.blockID == range.start.blockID)
        #expect(restored.selection.range.end.blockID == range.end.blockID)
        #expect(restored.selection.range.start.utf16Offset ==
            range.start.utf16Offset)
        #expect(restored.selection.range.end.utf16Offset ==
            range.end.utf16Offset)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .redo
        ))
        #expect(session.document.content == after)
        #expect(session.isDirty)
    }
}
