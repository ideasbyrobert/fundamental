import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingRecoveryTests
{
    @Test("newer writing and its checkpoint survive an older pending save")
    func pendingSave() async throws
    {
        let fixture = try WritingFileFixture()
        defer { fixture.remove() }
        let store = WritingRecoveryStore(directory:
            fixture.directory.appending(path: "Recovery"))
        let storage = WritingSuspendedStorage()
        let owner = WritingFileOwner(session: DocumentSession(
            state: try WritingTestDocument("A").state
        ), storage: storage)
        let recovery = WritingRecoveryCoordinator(owner: owner, store: store)
        owner.recovery = recovery
        defer { recovery.stop() }
        let saving = Task { try await owner.save(to: fixture.location) }
        await storage.waitForSave()
        let savedRevision = owner.session.document.revision.value
        let initial = try await store.catalog().records.first
        #expect(initial?.revision == savedRevision)
        let projection = try #require(WritingProjection(owner.session.state))
        let proposal = try #require(WritingTextProposal(
            ranges: [NSRange(location: 1, length: 0)], replacements: ["B"],
            in: projection
        ))
        owner.session.submit(proposal.command)
        let current = try #require(WritingProjection(owner.session.state))
        let checkpoint = try #require(recovery.capture(current.snapshot))
        await recovery.checkpoint(checkpoint)
        await storage.continueSave()
        try await saving.value
        #expect(owner.session.isDirty)
        let retained = try await store.catalog().records
        #expect(retained.count == 1)
        #expect(retained.first?.snapshot.snapshot.document ==
            owner.session.document)
        #expect(retained.first?.revision != savedRevision)
        try await recovery.discard()
        await recovery.checkpoint(checkpoint)
        #expect(try await store.catalog().records.isEmpty)
    }
}
