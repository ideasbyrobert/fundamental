import Testing

@testable import FundamentalDocument

extension DocumentSessionCodeConversionTests
{
    @Test("conversion undo restores source tags runs and directed selection")
    func exactHistory() throws
    {
        let runs = [SemanticRun(text: "A\r\ne\u{301}\r\t😀\n"),
                    SemanticRun(text: "", traits: [.strong])]
        let text = runs.map(\.text).joined()
        let source = try SemanticWritingTestDocument(blocks: [
            CodeConversionTestValue.code(runs, language: " SwIfT ")
        ])
        let range = try source.range((0, text.utf16.count), (0, 0))
        let session = DocumentSession(
            state: try source.state(range), initiallySaved: true
        )
        let conversion = try #require(SemanticCodeConversion(
            range: range, proseStyle: .numbered,
            continuationBlockIDs: CodeConversionTestValue.identities(3)
        ))
        let result = session.submit(.convertCode(
            session.observation, conversion
        ))
        guard case let .applied(.editable(after)) = result
        else
        {
            Issue.record("Expected a converted document")
            return
        }
        let converted = session.document.content
        #expect(session.history.undo.count == 1)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .undo
        ))
        #expect(session.document.content == source.document.content)
        #expect(!session.isDirty)
        #expect(session.canRedo)
        #expect(session.document.revision.value == 10)
        CodeConversionTestValue.expectText(session.document, [text])
        guard case let .editable(restored) = session.state
        else
        {
            Issue.record("Expected restored editable selection")
            return
        }
        #expect(restored.selection.range.start.blockID == range.start.blockID)
        #expect(restored.selection.range.start.utf16Offset ==
            range.start.utf16Offset)
        #expect(restored.selection.range.end.utf16Offset ==
            range.end.utf16Offset)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .redo
        ))
        #expect(session.document.content == converted)
        #expect(session.isDirty)
        #expect(session.document.revision.value == 11)
        guard case let .editable(redone) = session.state
        else
        {
            Issue.record("Expected redone selection")
            return
        }
        #expect(redone.selection.range.start.blockID ==
            after.selection.range.start.blockID)
        #expect(redone.selection.range.end.blockID ==
            after.selection.range.end.blockID)
        #expect(redone.selection.range.start.utf16Offset ==
            after.selection.range.start.utf16Offset)
    }
}
