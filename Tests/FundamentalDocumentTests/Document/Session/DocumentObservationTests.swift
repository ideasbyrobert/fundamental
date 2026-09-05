import Testing

@testable import FundamentalDocument

extension DocumentSessionTransitionTests
{
    @Test("an observation requires document revision and generation facts")
    func observation() throws
    {
        let fixture = try SessionTestDocument()
        let observation = fixture.observation
        #expect(observation.documentID
            == fixture.editable.snapshot.document.documentID)
        #expect(observation.revision == DocumentRevision(8))
        #expect(observation.generation == SnapshotGeneration(3))
    }

    @Test("session vocabulary retains equality and sendable conformance")
    func equalityAndSendable() throws
    {
        Self.requireSendable(DocumentObservation.self)
        Self.requireSendable(DocumentSessionCommand.self)
        Self.requireSendable(DocumentSessionRefusal.self)
        Self.requireSendable(DocumentSessionTransition.self)
        let fixture = try SessionTestDocument()
        #expect(fixture.observation == DocumentObservation(
            snapshot: fixture.state.snapshot
        ))
        #expect(DocumentSessionTransition.applied(fixture.state)
            == .applied(fixture.state))
        #expect(DocumentSessionTransition.unchanged != .applied(fixture.state))
    }
}
