import Foundation
import Testing

@testable import FundamentalWritingWitness

extension WritingRecoveryTests
{
    @Test("symlink and oversized checkpoint files remain untouched")
    func refusedFiles() async throws
    {
        let directory = try Self.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WritingRecoveryStore(directory: directory)
        let record = try Self.record("content")
        let location = await store.location(record.identifier)
        let destination = directory.appending(path: "precious.txt")
        try Data("keep".utf8).write(to: destination)
        try FileManager.default.createSymbolicLink(
            at: location, withDestinationURL: destination
        )
        await #expect(throws: (any Error).self)
        {
            try await store.checkpoint(record)
        }
        #expect(try Data(contentsOf: destination) == Data("keep".utf8))
        try FileManager.default.removeItem(at: location)
        #expect(FileManager.default.createFile(atPath: location.path,
                                               contents: Data()))
        let file = try FileHandle(forWritingTo: location)
        let size = UInt64(WritingRecoveryCodec.maximumBytes + 1)
        try file.truncate(atOffset: size)
        try file.close()
        let catalog = try await store.catalog()
        #expect(catalog.records.isEmpty)
        #expect(catalog.unreadable.map { $0.resolvingSymlinksInPath() } ==
            [location.resolvingSymlinksInPath()])
    }

    @Test("a checkpoint cannot impersonate another recovery identity")
    func identity() async throws
    {
        let directory = try Self.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WritingRecoveryStore(directory: directory)
        let record = try Self.record("identity")
        let renamed = directory.appending(path: UUID().uuidString + ".recovery")
        try WritingRecoveryCodec().encode(record).write(to: renamed)
        let catalog = try await store.catalog()
        #expect(catalog.records.isEmpty)
        #expect(catalog.unreadable.map { $0.resolvingSymlinksInPath() } ==
            [renamed.resolvingSymlinksInPath()])
    }
}
