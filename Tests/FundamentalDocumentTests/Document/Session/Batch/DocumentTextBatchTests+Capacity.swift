import Testing

@testable import FundamentalDocument

extension DocumentTextBatchTests
{
    @Test("history capacity refusal cannot publish any batch content")
    func historyCapacity() throws
    {
        let fixture = try SessionTestDocument()
        let batch = try Self.batch([(0, 0 ..< 2, "Changed")], in: fixture)
        let limits = try #require(DocumentHistoryLimits(
            transactions: 1, retainedUTF16Units: 1
        ))
        let session = DocumentSession(state: fixture.state,
            historyLimits: limits, initiallySaved: true)
        let before = session.current
        #expect(session.submit(.replace(fixture.observation, batch)) ==
            .refused(.historyCapacity))
        #expect(session.current == before)
        #expect(!session.isDirty)
    }

    @Test("exhausted snapshot or document counters refuse the complete batch",
          arguments: [true, false])
    func counterCapacity(_ generation: Bool) throws
    {
        let fixture = try SessionTestDocument(
            revision: generation ? 8 : .max,
            generation: generation ? .max : 3
        )
        let batch = try Self.batch([(0, 0 ..< 2, "X")], in: fixture)
        let session = DocumentSession(state: fixture.state)
        let refusal: DocumentSessionRefusal = generation
            ? .generationExhausted : .invalidCommand
        #expect(session.submit(.replace(fixture.observation, batch)) ==
            .refused(refusal))
        #expect(session.state == fixture.state)
        #expect(!session.canUndo)
    }

    @Test("identical spelling leaves selection, history and saving unchanged")
    func identicalSpelling() throws
    {
        let fixture = try SessionTestDocument()
        let batch = try Self.batch([(0, 0 ..< 2, "AB")], in: fixture)
        let session = DocumentSession(state: fixture.state,
                                       initiallySaved: true)
        let before = session.current
        let persistence = session.persistence
        let result = session.submit(.replace(fixture.observation, batch))
        #expect(result == .unchanged)
        #expect(session.current == before)
        Self.expectPersistence(session, persistence)
    }
}
