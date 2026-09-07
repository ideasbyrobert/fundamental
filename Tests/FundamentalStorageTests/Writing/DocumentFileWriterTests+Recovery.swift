import Foundation
import Testing

@testable import FundamentalStorage

extension DocumentFileWriterTests
{
    @Test("replacement errors retain recovery before releasing owners")
    func failedReplacement() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let previous = try DocumentFileReader(
            location: location, codec: DocumentFileFixture.codec
        ).read()
        let writer = try DocumentFileFixture.writer(
            at: location, condition: .unchanged(previous.revision)
        )
        let bytes = try DocumentFileFixture.codec.encode(writer.document)
        var candidate: DocumentFileCandidate? = try DocumentFileCandidate(
            bytes: bytes, destination: location
        )
        let directory = try #require(candidate?.directory)
        let pending = try #require(candidate?.url)
        try FileManager.default.removeItem(at: pending)
        do
        {
            let owned = try #require(candidate)
            _ = try writer.publish(owned, previous: previous, bytes: bytes)
            Issue.record("An absent replacement candidate was acknowledged.")
        }
        catch let DocumentFileFailure.unconfirmedWrite(recovery)
        {
            #expect(recovery.destination == location)
            #expect(recovery.locations.contains(directory))
            #expect(!recovery.errorDomain.isEmpty)
        }
        candidate = nil
        #expect(FileManager.default.fileExists(atPath: directory.path))
        #expect(try Data(contentsOf: location.url) ==
            DocumentFileFixture.record)
        try FileManager.default.removeItem(at: directory)
    }

    @Test("changed previous bytes are retained when verification refuses")
    func changedBackup() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let previous = try DocumentFileReader(
            location: location, codec: DocumentFileFixture.codec
        ).read()
        let writer = try DocumentFileFixture.writer(
            at: location, condition: .unchanged(previous.revision)
        )
        let bytes = try DocumentFileFixture.codec.encode(writer.document)
        let candidate = try DocumentFileCandidate(
            bytes: bytes, destination: location
        )
        let installed = try writer.replaceExisting(candidate)
        let backup = try #require(candidate.backupURL)
        let outside = try DocumentFileFixture.codec.encode(
            DocumentFileFixture.document("An intervening outside edit.")
        )
        try outside.write(to: backup)
        #expect(throws: DocumentFileFailure.conflictingRevision)
        {
            try writer.verify(
                installed: installed, previous: previous,
                bytes: bytes, candidate: candidate
            )
        }
        #expect(candidate.preserved)
        #expect(try Data(contentsOf: backup) == outside)
        #expect(try Data(contentsOf: installed.url) == bytes)
        #expect(candidate.discard().isEmpty)
    }
}
