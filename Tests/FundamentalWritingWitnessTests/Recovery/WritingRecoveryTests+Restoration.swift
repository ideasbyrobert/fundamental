import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingRecoveryTests
{
    @Test("recovery creates an unsaved owner without opening the original")
    func restoredOwner() async throws
    {
        let directory = try Self.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WritingRecoveryStore(directory: directory)
        let source = directory.appending(path: "Original.fun")
        try Data("Do not overwrite".utf8).write(to: source)
        let snapshot = try Self.record("Recovered writing").snapshot
        let record = try #require(WritingRecoveryRecord(
            identifier: UUID(), sequence: 7, name: "Original.fun",
            source: source, snapshot: snapshot
        ))
        try await store.checkpoint(record)
        let owner = WritingFileOwner.recover(record, store: store)
        let recovery = try #require(owner.recovery)
        defer { recovery.stop() }
        #expect(owner.binding == nil)
        #expect(owner.session.isDirty)
        #expect(!owner.session.canUndo)
        #expect(owner.isRecovered)
        #expect(owner.displayName == record.name)
        #expect(owner.recoverySource == source)
        #expect(owner.session.document == record.snapshot.snapshot.document)
        let current = try #require(WritingProjection(owner.session.state))
        #expect(current.snapshot.selection == record.snapshot.selection)
        let next = try #require(recovery.capture(current.snapshot))
        #expect(next.identifier == record.identifier)
        #expect(next.sequence == 8)
        #expect(next.name == record.name)
        await recovery.checkpoint(next)
        #expect(try Data(contentsOf: source) == Data("Do not overwrite".utf8))
        #expect(try await store.catalog().recoverable.count == 1)
    }
}
