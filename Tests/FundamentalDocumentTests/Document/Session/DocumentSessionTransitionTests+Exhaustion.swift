import Testing

@testable import FundamentalDocument

extension DocumentSessionTransitionTests
{
    @Test("terminal generation refuses edits and changed selections")
    func generationExhaustion() throws
    {
        let fixture = try SessionTestDocument(generation: .max)
        let commands: [DocumentSessionCommand] = [
            .edit(fixture.observation,
                  try SessionTestEdit.insertion.edit(in: fixture)),
            .select(fixture.observation, try fixture.selection(3, 1))
        ]
        for command in commands
        {
            #expect(DocumentSessionTransition(command, in: fixture.state)
                == .refused(.generationExhausted))
        }
        #expect(fixture.editable.snapshot.document.revision.value == 8)
    }

    @Test("terminal document revision still permits a selection change")
    func terminalRevisionSelection() throws
    {
        let fixture = try SessionTestDocument(revision: .max)
        let next = try Self.editable(DocumentSessionTransition(
            .select(fixture.observation, fixture.selection(3, 1)),
            in: fixture.state
        ))
        #expect(next.snapshot.document.revision.value == UInt64.max)
        #expect(next.snapshot.generation.value == 4)
    }

    @Test("terminal document revision refuses a content edit atomically")
    func revisionExhaustion() throws
    {
        let fixture = try SessionTestDocument(revision: .max)
        #expect(DocumentSessionTransition(
            .edit(fixture.observation,
                  try SessionTestEdit.insertion.edit(in: fixture)),
            in: fixture.state
        ) == .refused(.invalidCommand))
        #expect(fixture.editable.snapshot.generation.value == 3)
        #expect(fixture.editable.snapshot.document.revision.value == UInt64.max)
    }
}
