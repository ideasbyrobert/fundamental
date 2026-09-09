import Testing

@testable import FundamentalDocument

extension DocumentSessionStyleTests
{
    @Test("list removal preserves backward selection and one history step")
    func removeListsHistory() throws
    {
        let source = try SemanticWritingTestDocument(
            [.title, .numbered, .body, .bulleted],
            texts: ["A😀B", "B😀C", "P", "L"]
        )
        let range = try source.range((3, 1), (0, 1))
        let session = DocumentSession(
            state: try source.state(range), initiallySaved: true
        )
        let result = session.submit(.style(session.observation,
            SemanticBlockStyleChange(removingListsIn: range)
        ))
        guard case let .applied(.editable(after)) = result
        else
        {
            Issue.record("Expected one list removal")
            return
        }
        #expect(session.document.content.blocks.map
            { CanonicalBlockStyle($0.block) } == [.title, .body, .body, .body])
        #expect(session.document.content.blocks.map(\.blockID) ==
            source.document.content.blocks.map(\.blockID))
        #expect(after.selection.range.start.blockID == range.start.blockID)
        #expect(after.selection.range.end.blockID == range.end.blockID)
        #expect(after.selection.range.start.utf16Offset ==
            range.start.utf16Offset)
        #expect(after.selection.range.end.utf16Offset == range.end.utf16Offset)
        #expect(session.history.undo.count == 1)
        let removed = session.document.content
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .undo
        ))
        #expect(session.document.content == source.document.content)
        #expect(!session.isDirty)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .redo
        ))
        #expect(session.document.content == removed)
        #expect(session.isDirty)
    }

    @Test("removing lists from prose leaves saved state and history unchanged")
    func removeListsUnchanged() throws
    {
        let source = try SemanticWritingTestDocument([.title, .body])
        let range = try source.range((0, 0), (1, 4))
        let session = DocumentSession(
            state: try source.state(range), initiallySaved: true
        )
        let before = session.current
        #expect(session.submit(.style(session.observation,
            SemanticBlockStyleChange(removingListsIn: range)
        )) == .unchanged)
        #expect(session.current == before)
        #expect(!session.isDirty)
    }
}
