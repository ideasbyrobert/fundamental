import Testing

@testable import FundamentalDocument

extension DocumentTextBatchTests
{
    @Test("Unicode replacements publish one revision and one undo entry")
    func oneHistoryEntry() throws
    {
        let fixture = try SessionTestDocument(texts: [
            "A😀B e\u{301}", "мир мир"
        ])
        let batch = try Self.batch([
            (1, 4 ..< 7, "свет"), (0, 5 ..< 7, "é"),
            (0, 1 ..< 3, "👨‍👩‍👧‍👦")
        ], in: fixture)
        let selection = try fixture.selection(7, 0)
        let selected = try #require(EditableDocumentSnapshot(
            snapshot: fixture.editable.snapshot, selection: selection
        ))
        let session = DocumentSession(state: .editable(selected),
                                       initiallySaved: true)
        let original = try Self.spelling(session)
        guard case .applied = session.submit(
            .replace(fixture.observation, batch)
        )
        else
        {
            Issue.record("Expected an atomic Unicode replacement")
            return
        }
        #expect(try Self.spelling(session) ==
            ["A👨‍👩‍👧‍👦B é", "мир свет"].map { Array($0.utf16) })
        #expect(session.document.revision.value == 9)
        #expect(session.state.snapshot.generation.value == 4)
        #expect(session.history.undo.count == 1)
        #expect(session.isDirty)
        let changed = session.document.content
        try Self.move(session, .undo)
        #expect(try Self.spelling(session) == original)
        #expect(!session.isDirty)
        #expect(!session.canUndo && session.canRedo)
        guard case let .editable(restored) = session.state
        else
        {
            Issue.record("Undo must restore editable selection")
            return
        }
        #expect(restored.selection.range.start.utf16Offset.value == 7)
        #expect(restored.selection.range.end.utf16Offset.value == 0)
        try Self.move(session, .redo)
        #expect(session.document.content == changed)
        #expect(session.isDirty && session.canUndo && !session.canRedo)
    }

    @Test("empty replacements delete adjacent matches in one transaction")
    func adjacentDeletion() throws
    {
        let fixture = try SessionTestDocument(texts: ["A😀BC", "Keep"])
        let batch = try Self.batch([
            (0, 3 ..< 4, ""), (0, 1 ..< 3, "")
        ], in: fixture)
        let session = DocumentSession(state: fixture.state)
        session.submit(.replace(fixture.observation, batch))
        #expect(try Self.spelling(session) == ["AC", "Keep"].map
            { Array($0.utf16) })
        #expect(session.history.undo.count == 1)
        try Self.move(session, .undo)
        #expect(session.document.content == fixture.editable.snapshot
            .document.content)
    }
}
