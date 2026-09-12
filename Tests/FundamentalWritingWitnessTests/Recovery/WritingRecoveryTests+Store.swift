import Foundation
import Testing

@testable import FundamentalWritingWitness

extension WritingRecoveryTests
{
    @Test("reversed checkpoint completion cannot publish older writing")
    func staleCheckpoint() async throws
    {
        let directory = try Self.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WritingRecoveryStore(directory: directory)
        let identifier = UUID()
        let newer = try Self.record("new", identifier: identifier,
                                    revision: 10, sequence: 3)
        let older = try Self.record("old", identifier: identifier,
                                    revision: 9, sequence: 4)
        #expect(try await store.checkpoint(newer))
        #expect(try await !store.checkpoint(older))
        let catalog = try await store.catalog()
        #expect(catalog.records.count == 1)
        #expect(catalog.records.first?.revision == 10)
        #expect(catalog.records.first?.sequence == 3)
        let staleSelection = try Self.record("new", identifier: identifier,
                                             revision: 10, sequence: 2)
        #expect(try await !store.checkpoint(staleSelection))
    }

    @Test("an old save preserves a newer checkpoint and newer pending write")
    func savedRevision() async throws
    {
        let directory = try Self.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WritingRecoveryStore(directory: directory)
        let identifier = UUID()
        let saved = try Self.record("saved", identifier: identifier,
                                    revision: 9)
        let current = try Self.record("newer", identifier: identifier,
                                      revision: 10, sequence: 2)
        #expect(try await store.checkpoint(saved))
        #expect(try await store.checkpoint(current))
        #expect(try await !store.saved(identifier, revision: 9))
        #expect(try await store.catalog().records.first?.revision == 10)
        #expect(try await store.saved(identifier, revision: 10))
        #expect(try await store.catalog().records.isEmpty)
        #expect(try await !store.checkpoint(saved))
        #expect(try await !store.checkpoint(current))
        let later = try Self.record("latest", identifier: identifier,
                                    revision: 11, sequence: 3)
        #expect(try await store.checkpoint(later))
        #expect(try await store.catalog().records.first?.revision == 11)
    }

    @Test("explicit discard fences queued writes for that document only")
    func discardedCheckpoint() async throws
    {
        let directory = try Self.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WritingRecoveryStore(directory: directory)
        let discarded = try Self.record("discard")
        let retained = try Self.record("retain")
        try await store.checkpoint(discarded)
        try await store.checkpoint(retained)
        try await store.discard(discarded.identifier)
        let late = try Self.record("too late", identifier: discarded.identifier,
                                   revision: 50, sequence: 50)
        #expect(try await !store.checkpoint(late))
        let records = try await store.catalog().records
        #expect(records.map(\.identifier) == [retained.identifier])
    }
}
