import Testing

@testable import FundamentalDocument

extension DocumentTextBatchTests
{
    @Test("an invalid final range cannot publish an earlier valid replacement",
          arguments: [1 ..< 2, 3 ..< 4, 0 ..< 99])
    func invalidMember(_ offsets: Range<Int>) throws
    {
        let fixture = try SessionTestDocument(texts: ["Hello", "😀e\u{301}"])
        let batch = try Self.batch([
            (0, 0 ..< 5, "Changed"), (1, offsets, "X")
        ], in: fixture)
        let session = DocumentSession(state: fixture.state,
                                       initiallySaved: true)
        let ticket = session.prepareSave()
        let before = session.current
        let persistence = session.persistence
        #expect(session.submit(.replace(fixture.observation, batch)) ==
            .refused(.invalidCommand))
        #expect(session.current == before)
        Self.expectPersistence(session, persistence)
        #expect(session.acknowledgeSave(ticket))
    }

    @Test("overlapping and duplicate matches refuse the entire replacement",
          arguments: [1 ..< 3, 0 ..< 2])
    func overlap(_ second: Range<Int>) throws
    {
        let fixture = try SessionTestDocument()
        let batch = try Self.batch([
            (0, 0 ..< 2, "X"), (0, second, "Y")
        ], in: fixture)
        let session = DocumentSession(state: fixture.state)
        #expect(session.submit(.replace(fixture.observation, batch)) ==
            .refused(.invalidCommand))
        #expect(session.state == fixture.state)
        #expect(!session.canUndo)
    }

    @Test("stale observations and source ranges remain fenced")
    func staleResults() throws
    {
        let fixture = try SessionTestDocument()
        let batch = try Self.batch([(0, 0 ..< 2, "X")], in: fixture)
        let session = DocumentSession(state: fixture.state)
        session.submit(.replace(fixture.observation, batch))
        let before = session.current
        #expect(session.submit(.replace(fixture.observation, batch)) ==
            .refused(.staleObservation))
        #expect(session.submit(.replace(session.observation, batch)) ==
            .refused(.invalidCommand))
        #expect(session.current == before)
    }

    @Test("an empty batch and collapsed substitution cannot be constructed")
    func admission() throws
    {
        #expect(SemanticTextBatchReplacement([]) == nil)
        let fixture = try SessionTestDocument()
        let range = try fixture.selection(0, 0).range
        #expect(SemanticTextSubstitution(range: range, text: "X",
            attributes: .direct(traits: [])) == nil)
    }
}
