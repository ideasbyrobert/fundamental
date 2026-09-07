import Testing

@testable import FundamentalDocument

@Suite("Semantic styling through document ownership")
@MainActor
struct DocumentSessionStyleTests
{
    @Test("a backward selection keeps spelling identity and direction")
    func backwardSelection() throws
    {
        let source = try SemanticWritingTestDocument([.body, .title, .numbered])
        let range = try source.range((2, 2), (0, 1))
        let session = DocumentSession(state: try source.state(range))
        let result = session.submit(.style(session.observation,
            SemanticBlockStyleChange(range: range, style: .bulleted)
        ))
        guard case let .applied(.editable(after)) = result
        else
        {
            Issue.record("Expected the complete styled selection")
            return
        }
        #expect(session.document.content.blocks.map(\.blockID) ==
            source.document.content.blocks.map(\.blockID))
        #expect(SemanticWritingTestDocument.texts(session.document) ==
            ["ABCD", "ABCD", "ABCD"])
        #expect(session.document.content.blocks.allSatisfy
            { CanonicalBlockStyle($0.block) == .bulleted })
        #expect(after.selection.range.start.blockID == range.start.blockID)
        #expect(after.selection.range.end.blockID == range.end.blockID)
        #expect(after.selection.range.start.utf16Offset ==
            range.start.utf16Offset)
        #expect(after.selection.range.end.utf16Offset == range.end.utf16Offset)
        #expect(session.document.revision.value == 9)
        #expect(after.snapshot.generation.value == 4)
        #expect(session.history.undo.count == 1)
    }

    @Test("styling undo restores saved state and redo restores exact roles")
    func historyAndSave() throws
    {
        let source = try SemanticWritingTestDocument([.body])
        let range = try source.range((0, 1), (0, 3))
        let session = DocumentSession(
            state: try source.state(range), initiallySaved: true
        )
        session.submit(.style(session.observation,
            SemanticBlockStyleChange(range: range, style: .numbered)
        ))
        let styled = session.document.content
        #expect(session.isDirty)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .undo
        ))
        #expect(session.document.content == source.document.content)
        #expect(!session.isDirty)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .redo
        ))
        #expect(session.document.content == styled)
        #expect(session.isDirty)
        let ticket = session.prepareSave()
        #expect(session.acknowledgeSave(ticket))
        #expect(!session.isDirty)
    }
}
