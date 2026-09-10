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
        let change = SemanticBlockStyleChange(
            range: selection.range, style: .bulleted
        )
        let conversion = SemanticCodeConversion(range: selection.range)
        let inline = SemanticInlineTraitChange(
            range: selection.range, trait: .strong, enabled: true
        )
        let typing = SemanticInlineTraitAssignment(trait: .emphasis,
                                                   enabled: true)
        let input = DocumentInputTransaction(edit: edit, selection: selection)
        let assignment = try ScopeTestValue.assignments()[0]
        let scope = SemanticRunScopeChange(range: selection.range,
                                           assignment: assignment)
        let commands: [DocumentSessionCommand] = [
            .edit(fixture.observation, edit),
            .select(fixture.observation, selection),
            .style(fixture.observation, change),
            .convertCode(fixture.observation, conversion),
            .inline(fixture.observation, inline),
            .typing(fixture.observation, typing),
            .input(fixture.observation, input),
            .scope(fixture.observation, scope),
            .typingScope(fixture.observation, assignment)
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
            case let .style(observation, value):
                #expect(observation == fixture.observation)
                #expect(value == change)
            case let .convertCode(observation, value):
                #expect(observation == fixture.observation)
                #expect(value == conversion)
                #expect(command.changesContent)
            case let .inline(observation, value):
                #expect(observation == fixture.observation)
                #expect(value == inline)
                #expect(command.changesContent)
            case let .typing(observation, value):
                #expect(observation == fixture.observation)
                #expect(value == typing)
                #expect(!command.changesContent)
            case let .input(observation, value):
                #expect(observation == fixture.observation)
                #expect(value == input)
                #expect(command.changesContent)
            case let .scope(observation, value):
                #expect(observation == fixture.observation)
                #expect(value == scope)
                #expect(command.changesContent)
            case let .typingScope(observation, value):
                #expect(observation == fixture.observation)
                #expect(value == assignment)
                #expect(!command.changesContent)
            }
        }
        #expect(commands[0] != commands[1])
    }
}
