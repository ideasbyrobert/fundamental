import Testing

@testable import FundamentalDocument

extension DocumentSessionTests
{
    @Test
    func submissionMatchesPureTransition() throws
    {
        let fixture = try SessionTestDocument()
        let edit = try SessionTestEdit.insertion.edit(in: fixture)
        let commands: [DocumentSessionCommand] = [
            .select(fixture.observation, fixture.editable.selection),
            .edit(fixture.observation, edit),
            .edit(fixture.observation, edit)
        ]
        let session = DocumentSession(state: fixture.state)
        for command in commands
        {
            let before = session.state
            let expected = DocumentSessionTransition(command, in: before)
            #expect(session.submit(command) == expected)
            switch expected
            {
            case let .applied(successor):
                #expect(session.state == successor)
            case .unchanged, .refused:
                #expect(session.state == before)
            }
        }
    }

    @Test
    func independentOwnersRetainTheirOwnStates() throws
    {
        let fixture = try SessionTestDocument()
        let first = DocumentSession(state: fixture.state)
        let second = DocumentSession(state: fixture.state)
        let command = DocumentSessionCommand.edit(
            first.observation,
            try SessionTestEdit.insertion.edit(in: fixture)
        )
        first.submit(command)
        #expect(first !== second)
        #expect(first.state != fixture.state)
        #expect(second.state == fixture.state)
        #expect(second.observation == fixture.observation)
    }
}
