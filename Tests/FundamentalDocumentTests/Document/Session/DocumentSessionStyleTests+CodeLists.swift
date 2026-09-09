import Testing

@testable import FundamentalDocument

extension DocumentSessionStyleTests
{
    @Test(arguments: [false, true])
    func removeMixedCodeListsPreservesSourceAndHistory(tagged: Bool) throws
    {
        let runs = try BlockRecordTestValue.runs() +
            [SemanticRun(text: "A\r\nB\r")]
        let code = try CodeConversionTestValue.code(
            runs, language: tagged ? " e\u{301} Swift " : nil
        )
        let source = try SemanticWritingTestDocument(blocks: [
            CanonicalBlockStyle.title.semanticBlock(
                runs: [SemanticRun(text: "Title")]
            ), code, CanonicalBlockStyle.numbered.semanticBlock(
                runs: [SemanticRun(text: "List")]
            )
        ])
        let range = try source.range((2, 4), (0, 0))
        let session = DocumentSession(
            state: try source.state(range), initiallySaved: true
        )
        let result = session.submit(.style(session.observation,
            SemanticBlockStyleChange(removingListsIn: range)
        ))
        guard case let .applied(.editable(after)) = result
        else
        {
            Issue.record("Expected only the list role to change")
            return
        }
        let blocks = session.document.content.blocks
        #expect(blocks[0] == source.document.content.blocks[0])
        #expect(blocks[1] == source.document.content.blocks[1])
        let preserved = try CodeConversionTestValue.runs(blocks[1])
        for (original, retained) in zip(runs, preserved)
        {
            #expect(original.text.utf16.elementsEqual(retained.text.utf16))
        }
        #expect(blocks[2].block == .paragraph(SemanticParagraph(
            runs: [SemanticRun(text: "List")]
        )))
        #expect(blocks.map(\.blockID) ==
            source.document.content.blocks.map(\.blockID))
        #expect(after.selection.range.start.blockID == range.start.blockID)
        #expect(after.selection.range.end.blockID == range.end.blockID)
        #expect(after.selection.range.start.utf16Offset.value == 4)
        #expect(after.selection.range.end.utf16Offset.value == 0)
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

    @Test
    func removingListsFromCodeLeavesHistoryAndSavedStateUnchanged() throws
    {
        let code = try CodeConversionTestValue.code(
            [SemanticRun(text: "A\r\nB\r")], language: "Swift"
        )
        let source = try SemanticWritingTestDocument(blocks: [code])
        let session = DocumentSession(
            state: try source.state(), initiallySaved: true
        )
        let before = session.current
        #expect(try session.submit(.style(session.observation,
            SemanticBlockStyleChange(
                removingListsIn: source.range((0, 0), (0, 0))
            )
        )) == .unchanged)
        #expect(session.current == before)
        #expect(!session.isDirty)
    }
}
