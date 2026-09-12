import Foundation
import FundamentalStorage
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingRecoveryTests
{
    @Test("explicit Save checkpoints and retires its exact canonical revision")
    func saving() async throws
    {
        let fixture = try WritingFileFixture()
        defer { fixture.remove() }
        let store = WritingRecoveryStore(directory:
            fixture.directory.appending(path: "Recovery"))
        let owner = WritingFileOwner(session: DocumentSession(
            state: try WritingTestDocument("Saved writing").state
        ))
        let recovery = WritingRecoveryCoordinator(owner: owner, store: store)
        owner.recovery = recovery
        defer { recovery.stop() }
        try await owner.save(to: fixture.location)
        #expect(!owner.session.isDirty)
        #expect(try await store.catalog().records.isEmpty)
        #expect(recovery.lastError == nil)
        let file = try await DocumentFileStore().read(fixture.location)
        #expect(file.document == owner.session.document)
    }

    @Test("a save conflict retains the unsaved checkpoint and original file")
    func saveConflict() async throws
    {
        let fixture = try WritingFileFixture()
        defer { fixture.remove() }
        let store = WritingRecoveryStore(directory:
            fixture.directory.appending(path: "Recovery"))
        let owner = WritingFileOwner(session: DocumentSession(
            state: try WritingTestDocument("Unsaved writing").state
        ))
        let recovery = WritingRecoveryCoordinator(owner: owner, store: store)
        owner.recovery = recovery
        defer { recovery.stop() }
        try Data("Keep the original".utf8).write(to: fixture.location.url)
        await #expect(throws: DocumentFileFailure.destinationExists)
        {
            try await owner.save(to: fixture.location)
        }
        #expect(owner.session.isDirty)
        #expect(owner.binding == nil)
        let records = try await store.catalog().records
        #expect(records.first?.snapshot.snapshot.document ==
            owner.session.document)
        #expect(try Data(contentsOf: fixture.location.url) ==
            Data("Keep the original".utf8))
    }

    @Test("recovery failure cannot prevent explicit Save")
    func recoveryFailure() async throws
    {
        let fixture = try WritingFileFixture()
        defer { fixture.remove() }
        let blocked = fixture.directory.appending(path: "Not a directory")
        try Data("keep".utf8).write(to: blocked)
        let store = WritingRecoveryStore(directory: blocked)
        let owner = WritingFileOwner(session: DocumentSession(
            state: try WritingTestDocument("Important writing").state
        ))
        let recovery = WritingRecoveryCoordinator(owner: owner, store: store)
        owner.recovery = recovery
        defer { recovery.stop() }
        var warnings: [String] = []
        recovery.didFail = { warnings.append($0) }
        try await owner.save(to: fixture.location)
        #expect(!owner.session.isDirty)
        #expect(!warnings.isEmpty)
        #expect(try Data(contentsOf: blocked) == Data("keep".utf8))
    }
}
