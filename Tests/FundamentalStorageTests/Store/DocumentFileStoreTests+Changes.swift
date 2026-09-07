import Darwin
import Foundation
import Testing

@testable import FundamentalStorage

extension DocumentFileStoreTests
{
    @Test("restored modification time cannot hide a same size content change")
    func restoredModificationTime() async throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let store = DocumentFileStore()
        let first = try await store.read(location)
        var value = stat()
        #expect(lstat(location.url.path, &value) == 0)
        var times = [value.st_atimespec, value.st_mtimespec]
        let spelling = String(
            decoding: DocumentFileFixture.record, as: UTF8.self
        )
        let changed = spelling.replacingOccurrences(
            of: "9007199254740993", with: "9007199254740994"
        )
        try Data(changed.utf8).write(to: location.url)
        #expect(utimensat(AT_FDCWD, location.url.path, &times, 0) == 0)
        let second = try await store.read(location)
        #expect(first.revision.stamp.byteCount ==
            second.revision.stamp.byteCount)
        #expect(first.revision.stamp.modifiedSeconds ==
            second.revision.stamp.modifiedSeconds)
        #expect(first.revision.stamp.modifiedNanoseconds ==
            second.revision.stamp.modifiedNanoseconds)
        #expect(first.revision.digest != second.revision.digest)
        #expect(first.revision != second.revision)
    }

    @Test("coordination does not resolve a refused final symbolic link")
    func coordinatedSymbolicLink() async throws
    {
        let fixture = try DocumentFileFixture()
        let original = try fixture.write()
        let link = try fixture.location("Link")
        try FileManager.default.createSymbolicLink(
            at: link.url, withDestinationURL: original.url
        )
        await #expect(throws: DocumentFileFailure.fileSystem(ELOOP))
        {
            try await DocumentFileStore().read(link)
        }
    }
}
