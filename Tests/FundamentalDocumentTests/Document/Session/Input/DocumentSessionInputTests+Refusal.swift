import Testing

@testable import FundamentalDocument

extension DocumentSessionInputTests
{
    @Test("invalid completion refuses the edit and every related state change")
    func invalidCompletion() throws
    {
        let fixture = try DocumentInputTestFixture()
        guard case let .editable(source) = fixture.state
        else
        {
            throw SessionTestFailure.expectedEditable
        }
        let invalid = [source.selection, try fixture.selection(1),
                       try fixture.selection(3), try fixture.selection(99),
                       try fixture.selection(0, 2)]
        for selection in invalid
        {
            let session = DocumentSession(state: fixture.state,
                                          initiallySaved: true)
            let before = session.current
            let result = session.submit(fixture.command(
                selection, intent: fixture.intent
            ))
            #expect(result == .refused(.invalidCommand))
            #expect(session.current == before && !session.isDirty)
        }
    }

    @Test("stale read-only and capacity refusals remain atomic")
    func admission() throws
    {
        let fixture = try DocumentInputTestFixture()
        let command = try fixture.command(fixture.selection(2),
                                           intent: fixture.intent)
        let readonly = DocumentSession(state: .readable(fixture.state.snapshot))
        #expect(readonly.submit(command) == .refused(.readOnly))
        let session = DocumentSession(state: fixture.state)
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: .underline, enabled: true)
        ))
        let before = session.current
        #expect(session.submit(command) == .refused(.staleObservation))
        #expect(session.current == before)
        let limits = try #require(DocumentHistoryLimits(transactions: 1,
                                                        retainedUTF16Units: 1))
        let limited = DocumentSession(state: fixture.state,
                                      historyLimits: limits)
        let retained = limited.current
        #expect(limited.submit(command) == .refused(.historyCapacity))
        #expect(limited.current == retained)
    }
}
