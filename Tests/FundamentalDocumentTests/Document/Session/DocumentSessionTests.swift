import Testing

@testable import FundamentalDocument

@Suite("Canonical document session")
@MainActor
struct DocumentSessionTests
{
    @Test
    func initializationPreservesEitherState() throws
    {
        let fixture = try SessionTestDocument()
        let states: [DocumentSessionState] = [
            fixture.state,
            .readable(fixture.editable.snapshot)
        ]
        for state in states
        {
            let session = DocumentSession(state: state)
            #expect(session.state == state)
            #expect(session.observation == fixture.observation)
        }
    }

    @Test
    func readableSessionRefusesCommands() throws
    {
        let fixture = try SessionTestDocument()
        let state = DocumentSessionState.readable(fixture.editable.snapshot)
        let session = DocumentSession(state: state)
        let edit = try SessionTestEdit.insertion.edit(in: fixture)
        let commands: [DocumentSessionCommand] = [
            .edit(session.observation, edit),
            .select(session.observation, try fixture.selection(1, 2))
        ]
        for command in commands
        {
            #expect(session.submit(command) == .refused(.readOnly))
            #expect(session.state == state)
        }
    }

    @Test
    func referenceAliasesObserveOneOwner() throws
    {
        let fixture = try SessionTestDocument()
        let session = DocumentSession(state: fixture.state)
        let alias = session
        let command = DocumentSessionCommand.select(
            session.observation,
            try fixture.selection(3, 1)
        )
        let expected = DocumentSessionTransition(command, in: fixture.state)
        #expect(session === alias)
        #expect(alias.submit(command) == expected)
        #expect(session.state == alias.state)
        #expect(session.state.snapshot.generation == SnapshotGeneration(4))
        #expect(session.observation != fixture.observation)
    }
}
