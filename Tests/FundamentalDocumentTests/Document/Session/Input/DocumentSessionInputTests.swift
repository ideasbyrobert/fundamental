import Testing

@testable import FundamentalDocument

@MainActor
@Suite("Input completion is one canonical transaction")
struct DocumentSessionInputTests
{
    @Test("edit selection and typing state publish together with one history")
    func completion() throws
    {
        let fixture = try DocumentInputTestFixture()
        let session = DocumentSession(state: fixture.state,
                                      initiallySaved: true)
        let before = session.current
        let selection = try fixture.selection(2)
        let command = fixture.command(selection, intent: fixture.intent)
        let preview = DocumentSessionTransition(command, in: session.state)
        #expect(session.current == before)
        #expect(session.submit(command) == preview)
        guard case let .applied(.editable(after)) = preview
        else
        {
            Issue.record("Expected an atomic input completion")
            return
        }
        #expect(after.snapshot == fixture.destination)
        #expect(after.selection == selection)
        #expect(after.typingIntent == fixture.intent)
        #expect(session.history.undo.count == 1 && session.isDirty)
        CodeConversionTestValue.expectText(session.document, ["e\u{301}😀AB"])
        for direction in [DocumentHistoryDirection.undo, .redo]
        {
            session.submit(DocumentHistoryCommand(
                observation: session.observation, direction: direction
            ))
            let expected = direction == .undo ? fixture.state : .editable(after)
            guard case let .editable(current) = session.state,
                  case let .editable(expected) = expected
            else
            {
                Issue.record("Expected restored input state")
                return
            }
            #expect(current.snapshot.document.content ==
                expected.snapshot.document.content)
            #expect(current.selection.range.start.utf16Offset ==
                expected.selection.range.start.utf16Offset)
            #expect(current.typingIntent == expected.typingIntent)
            #expect(session.isDirty == (direction == .redo))
        }
    }

    @Test("a directed completion can select text without a typing override")
    func directed() throws
    {
        let fixture = try DocumentInputTestFixture()
        let session = DocumentSession(state: fixture.state)
        let selected = try fixture.selection(4, 0)
        guard case let .applied(.editable(after)) = session.submit(
            fixture.command(selected)
        )
        else
        {
            Issue.record("Expected a directed input selection")
            return
        }
        #expect(after.selection == selected && after.typingIntent == nil)
        #expect(session.history.undo.count == 1)
    }
}
