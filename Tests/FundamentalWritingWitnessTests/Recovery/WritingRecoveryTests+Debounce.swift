import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingRecoveryTests
{
    @Test("the timer checkpoints committed selection after editing settles")
    func debounce() async throws
    {
        let directory = try Self.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WritingRecoveryStore(directory: directory)
        let owner = WritingFileOwner(session: DocumentSession(
            state: try WritingTestDocument("A").state
        ))
        let recovery = WritingRecoveryCoordinator(owner: owner, store: store)
        defer { recovery.stop() }
        let original = try #require(WritingProjection(owner.session.state))
        recovery.observe(original)
        try await Task.sleep(for: .milliseconds(300))
        #expect(try await store.catalog().records.isEmpty)
        let proposal = try #require(WritingTextProposal(
            ranges: [NSRange(location: 1, length: 0)], replacements: ["😀"],
            in: original
        ))
        owner.session.submit(proposal.command)
        let current = try #require(WritingProjection(owner.session.state))
        recovery.observe(current)
        try await Task.sleep(for: .milliseconds(1800))
        #expect(try await store.catalog().records.isEmpty)
        let deadline = ContinuousClock.now.advanced(by: .seconds(3))
        var records = try await store.catalog().records
        while records.isEmpty && ContinuousClock.now < deadline
        {
            try await Task.sleep(for: .milliseconds(20))
            records = try await store.catalog().records
        }
        let record = try #require(records.first)
        #expect(record.snapshot.snapshot.document == owner.session.document)
        #expect(record.snapshot.selection == current.snapshot.selection)
        #expect(recovery.pending == nil)
        #expect(recovery.schedule.deadline == nil)
    }
}
