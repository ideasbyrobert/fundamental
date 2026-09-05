import Testing

@testable import FundamentalDocument

extension DocumentSessionTransitionTests
{
    @Test("commands exhaustively retain their observation and payload")
    func commands() throws
    {
        let fixture = try SessionTestDocument()
        let edit = try SessionTestEdit.insertion.edit(in: fixture)
        let selection = try fixture.selection(3, 1)
        let commands: [DocumentSessionCommand] = [
            .edit(fixture.observation, edit),
            .select(fixture.observation, selection)
        ]
        for command in commands
        {
            #expect(command.observation == fixture.observation)
            switch command
            {
            case let .edit(observation, value):
                #expect(observation == fixture.observation)
                #expect(value == edit)
            case let .select(observation, value):
                #expect(observation == fixture.observation)
                #expect(value == selection)
            }
        }
        #expect(commands[0] != commands[1])
    }
}
