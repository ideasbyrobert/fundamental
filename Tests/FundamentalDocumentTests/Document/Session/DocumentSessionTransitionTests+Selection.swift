import Testing

@testable import FundamentalDocument

extension DocumentSessionTransitionTests
{
    @Test("changed directional selection advances only generation")
    func changedSelection() throws
    {
        let fixture = try SessionTestDocument()
        let selection = try fixture.selection(3, 1)
        let next = try Self.editable(DocumentSessionTransition(
            .select(fixture.observation, selection),
            in: fixture.state
        ))
        #expect(next.selection == selection)
        #expect(next.snapshot.document == fixture.editable.snapshot.document)
        #expect(next.snapshot.generation.value == 4)
        let reversed = try fixture.selection(1, 3)
        let following = try Self.editable(DocumentSessionTransition(
            .select(DocumentObservation(snapshot: next.snapshot), reversed),
            in: .editable(next)
        ))
        #expect(following.selection == reversed)
        #expect(following.snapshot.generation.value == 5)
        #expect(following.snapshot.document.revision.value == 8)
    }

    @Test("identical selection consumes neither revision nor generation")
    func unchangedSelection() throws
    {
        let fixture = try SessionTestDocument()
        let result = DocumentSessionTransition(
            .select(fixture.observation, fixture.editable.selection),
            in: fixture.state
        )
        #expect(result == .unchanged)
        #expect(fixture.editable.snapshot.generation.value == 3)
        #expect(fixture.editable.snapshot.document.revision.value == 8)
    }

    @Test("identical selection remains unchanged at terminal generation")
    func terminalUnchangedSelection() throws
    {
        let fixture = try SessionTestDocument(generation: .max)
        #expect(DocumentSessionTransition(
            .select(fixture.observation, fixture.editable.selection),
            in: fixture.state
        ) == .unchanged)
    }

    @Test("invalid character selections refuse without succession")
    func invalidSelection() throws
    {
        let fixture = try SessionTestDocument(texts: ["\u{1F642}BCD"])
        for selection in [try fixture.selection(1, 2),
                          try fixture.selection(0, 100)]
        {
            #expect(DocumentSessionTransition(
                .select(fixture.observation, selection),
                in: fixture.state
            ) == .refused(.invalidCommand))
        }
        #expect(fixture.editable.snapshot.generation.value == 3)
        #expect(fixture.editable.selection.isCollapsed)
    }
}
