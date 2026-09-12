import Foundation
import Testing

@testable import FundamentalWritingWitness

extension WritingRecoveryTests
{
    @Test("malformed recovery metadata cannot create a partial document")
    func invalidEnvelope() throws
    {
        let codec = WritingRecoveryCodec()
        let data = try codec.encode(Self.record("e\u{301} 😀"))
        let object = try #require(JSONSerialization.jsonObject(with: data)
            as? [String: Any])
        var version = object
        version["version"] = 2
        #expect(throws: (any Error).self)
        {
            try codec.decode(JSONSerialization.data(withJSONObject: version))
        }
        var splitCharacter = object
        var anchor = try #require(object["anchor"] as? [String: Any])
        anchor["offset"] = 1
        splitCharacter["anchor"] = anchor
        #expect(throws: (any Error).self)
        {
            try codec.decode(JSONSerialization.data(
                withJSONObject: splitCharacter
            ))
        }
        #expect(throws: (any Error).self)
        {
            try codec.decode(Data("{broken}".utf8))
        }
    }

    @Test("a corrupt checkpoint is retained without hiding valid recovery")
    func corruptCatalog() async throws
    {
        let directory = try Self.directory()
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WritingRecoveryStore(directory: directory)
        let record = try Self.record("valid")
        try await store.checkpoint(record)
        let broken = directory.appending(path: UUID().uuidString + ".recovery")
        try Data("broken".utf8).write(to: broken)
        let catalog = try await store.catalog()
        #expect(catalog.records.map(\.identifier) == [record.identifier])
        #expect(catalog.unreadable.map { $0.resolvingSymlinksInPath() } ==
            [broken.resolvingSymlinksInPath()])
        #expect(try Data(contentsOf: broken) == Data("broken".utf8))
        let freshStore = WritingRecoveryStore(directory: directory)
        #expect(try await !freshStore.checkpoint(record))
    }
}
