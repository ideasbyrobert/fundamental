import Testing

@testable import FundamentalDocument

@Suite("Scoped formatting through document ownership")
@MainActor
struct DocumentSessionScopeTests
{
    @Test("scope history retains directed selection source and redo")
    func history() throws
    {
        let source = try SemanticWritingTestDocument(
            [.body, .monostyled, .numbered], texts: ["AB", "e\u{301}\r\n", "CD"]
        )
        let range = try source.range((2, 1), (0, 1))
        let session = DocumentSession(state: try source.state(range),
                                      initiallySaved: true)
        guard case let .applied(.editable(after)) = session.submit(.scope(
            session.observation, SemanticRunScopeChange(range: range,
                assignment: try ScopeTestValue.assignments()[0])
        ))
        else
        {
            Issue.record("Expected one scoped formatting transaction")
            return
        }
        let changed = session.document.content
        #expect(session.document.revision.value == 9)
        #expect(after.snapshot.generation.value == 4)
        #expect(session.history.undo.count == 1 && session.isDirty)
        for direction in [DocumentHistoryDirection.undo, .redo]
        {
            session.submit(DocumentHistoryCommand(
                observation: session.observation, direction: direction
            ))
            let current = try DocumentSessionTypingTests.editable(session)
            let selection = current.selection.range
            #expect(selection.start.blockID == range.start.blockID)
            #expect(selection.end.blockID == range.end.blockID)
            #expect(selection.start.utf16Offset == range.start.utf16Offset)
            #expect(selection.end.utf16Offset == range.end.utf16Offset)
            #expect(session.document.content ==
                (direction == .undo ? source.document.content : changed))
            #expect(session.isDirty == (direction == .redo))
            if direction == .undo
            {
                let before = session.current
                #expect(session.submit(.scope(session.observation,
                    SemanticRunScopeChange(range: current.selection.range,
                                           assignment: .link(nil))
                )) == .unchanged)
                #expect(session.current == before && session.canRedo)
            }
        }
        #expect(session.document.revision.value == 11)
        CodeConversionTestValue.expectText(session.document,
                                           ["AB", "e\u{301}\r\n", "CD"])
    }
}
