import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalStorage

@Suite("Coordinated document observations")
struct DocumentFileStoreTests
{
    @Test("repeated coordinated reads retain one unchanged observation")
    func repeatedRead() async throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let store = DocumentFileStore()
        let first = try await store.read(location)
        let second = try await store.read(location)
        #expect(first.document == second.document)
        #expect(first.revision == second.revision)
        #expect(first.location == location)
    }

    @Test("failed coordination or decoding publishes no successful read")
    func failedReads() async throws
    {
        let fixture = try DocumentFileFixture()
        let missing = try fixture.location()
        let invalid = try fixture.write(Data("{".utf8), name: "Invalid")
        let store = DocumentFileStore()
        for location in [missing, invalid]
        {
            await #expect(throws: (any Error).self)
            {
                try await store.read(location)
            }
        }
    }

    @Test("parent directory aliases retain their explicit local location")
    func parentAlias() async throws
    {
        let fixture = try DocumentFileFixture()
        let original = try fixture.write()
        let alias = fixture.root.appending(path: "Parent")
        try FileManager.default.createSymbolicLink(
            at: alias, withDestinationURL: fixture.root
        )
        let location = try #require(DocumentFileLocation(
            alias.appending(path: original.url.lastPathComponent)
        ))
        let read = try await DocumentFileStore().read(location)
        #expect(read.location == location)
        #expect(read.document.revision.value == 9_007_199_254_740_993)
    }
}
