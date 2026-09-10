import Testing

@testable import FundamentalDocument

extension DocumentSessionStyleTests
{
    @Test("all heading levels retain scoped runs selection history and files",
          arguments: SemanticHeadingLevel.allCases)
    func exactHeadingOwnership(_ level: SemanticHeadingLevel) throws
    {
        let runs = try HeadingTestValue.runs()
        let styles: [CanonicalBlockStyle] = [.body, .title, .numbered]
        let source = try SemanticWritingTestDocument(
            blocks: styles.map { $0.semanticBlock(runs: runs) }
        )
        let count = runs.map(\.text).joined().utf16.count
        let range = try source.range((2, count), (0, 2))
        let session = DocumentSession(
            state: try source.state(range), initiallySaved: true
        )
        let style = try HeadingTestValue.style(level)
        let result = session.submit(.style(session.observation,
            SemanticBlockStyleChange(range: range, style: style)
        ))
        guard case let .applied(.editable(after)) = result
        else
        {
            Issue.record("Expected the complete heading assignment")
            return
        }
        HeadingTestValue.expect(session.document, level: level, runs: runs)
        #expect(session.document.documentID == source.document.documentID)
        #expect(session.document.content.blocks.map(\.blockID) ==
            source.document.content.blocks.map(\.blockID))
        #expect(after.selection.range.start.blockID == range.start.blockID)
        #expect(after.selection.range.end.blockID == range.end.blockID)
        #expect(after.selection.range.start.utf16Offset.value == count)
        #expect(after.selection.range.end.utf16Offset.value == 2)
        #expect(session.history.undo.count == 1)
        let unchanged = session.current
        #expect(session.submit(.style(session.observation,
            SemanticBlockStyleChange(range: after.selection.range, style: style)
        )) == .unchanged)
        #expect(session.current == unchanged)
        let styled = session.document.content
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .undo
        ))
        #expect(session.document.content == source.document.content)
        #expect(!session.isDirty && session.canRedo)
        session.submit(DocumentHistoryCommand(
            observation: session.observation, direction: .redo
        ))
        #expect(session.document.content == styled)
        let ticket = session.prepareSave()
        let codec = DocumentRecordCodec(limits: DocumentRecordLimits())
        let bytes = try codec.encode(ticket.document)
        let reopened = try codec.decode(bytes)
        #expect(reopened == ticket.document)
        #expect(try codec.encode(reopened) == bytes)
        HeadingTestValue.expect(reopened, level: level, runs: runs)
        #expect(session.acknowledgeSave(ticket))
        #expect(!session.isDirty)
    }
}
