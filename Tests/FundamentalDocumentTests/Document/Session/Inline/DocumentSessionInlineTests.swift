import Testing

@testable import FundamentalDocument

@Suite("Inline formatting through document ownership")
@MainActor
struct DocumentSessionInlineTests
{
    @Test("one history step restores exact source and directed selection")
    func history() throws
    {
        let source = try SemanticWritingTestDocument(
            [.body, .monostyled, .numbered], texts: ["AB", "e\u{301}\r\n", "CD"]
        )
        let range = try source.range((2, 1), (0, 1))
        let session = DocumentSession(
            state: try source.state(range), initiallySaved: true
        )
        let result = session.submit(.inline(session.observation,
            SemanticInlineTraitChange(range: range, trait: .strong,
                                      enabled: true)
        ))
        guard case let .applied(.editable(after)) = result
        else
        {
            Issue.record("Expected the formatted source")
            return
        }
        let changed = session.document.content
        #expect(session.document.revision.value == 9)
        #expect(after.snapshot.generation.value == 4)
        #expect(session.history.undo.count == 1)
        #expect(session.isDirty)
        for direction in [DocumentHistoryDirection.undo, .redo]
        {
            session.submit(DocumentHistoryCommand(
                observation: session.observation, direction: direction
            ))
            guard case let .editable(current) = session.state
            else
            {
                Issue.record("Expected retained selection")
                return
            }
            #expect(current.selection.range.start.blockID ==
                range.start.blockID)
            #expect(current.selection.range.end.blockID == range.end.blockID)
            #expect(current.selection.range.start.utf16Offset ==
                range.start.utf16Offset)
            #expect(current.selection.range.end.utf16Offset ==
                range.end.utf16Offset)
            #expect(session.document.content ==
                (direction == .undo ? source.document.content : changed))
            #expect(session.isDirty == (direction == .redo))
            if direction == .undo
            {
                let before = session.current
                #expect(session.submit(.inline(session.observation,
                    SemanticInlineTraitChange(range: current.selection.range,
                                              trait: .strong, enabled: false)
                )) == .unchanged)
                #expect(session.current == before)
                #expect(session.canRedo)
            }
        }
        #expect(session.document.revision.value == 11)
        CodeConversionTestValue.expectText(session.document,
                                           ["AB", "e\u{301}\r\n", "CD"])
    }
}
