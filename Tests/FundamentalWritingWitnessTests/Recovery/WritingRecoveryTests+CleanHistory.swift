import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingRecoveryTests
{
    @Test("undoing to saved content supersedes the old unsaved checkpoint")
    func undoToSaved() async throws
    {
        let directory = try Self.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WritingRecoveryStore(directory: directory)
        let owner = WritingFileOwner(session: DocumentSession(
            state: try WritingTestDocument("A").state, initiallySaved: true
        ))
        let recovery = WritingRecoveryCoordinator(owner: owner, store: store)
        defer { recovery.stop() }
        let original = try #require(WritingProjection(owner.session.state))
        recovery.observe(original)
        let proposal = try #require(WritingTextProposal(
            ranges: [NSRange(location: 1, length: 0)], replacements: ["B"],
            in: original
        ))
        owner.session.submit(proposal.command)
        let changed = try #require(WritingProjection(owner.session.state))
        recovery.observe(changed)
        let checkpoint = try #require(recovery.capture(changed.snapshot))
        await recovery.checkpoint(checkpoint)
        let unsaved = try await store.catalog().records.first
        #expect(unsaved?.requiresRecovery == true)
        owner.session.submit(DocumentHistoryCommand(
            observation: changed.observation, direction: .undo
        ))
        let clean = try #require(WritingProjection(owner.session.state))
        #expect(!owner.session.isDirty)
        recovery.observe(clean)
        await recovery.pending?.value
        let records = try await store.catalog().records
        let latest = try #require(records.first)
        #expect(latest.snapshot.snapshot.document == owner.session.document)
        #expect(!latest.requiresRecovery)
        #expect(try await store.catalog().recoverable.isEmpty)
        #expect(recovery.capture(changed.snapshot) == nil)
        #expect(try WritingRecoveryCodec().decode(
            WritingRecoveryCodec().encode(latest)
        ).requiresRecovery == false)
        #expect(try await !store.checkpoint(checkpoint))
        try await recovery.discard()
        #expect(try await store.catalog().records.isEmpty)
    }
}
