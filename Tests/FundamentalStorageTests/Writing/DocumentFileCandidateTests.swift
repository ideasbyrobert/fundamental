import Foundation
import Testing

@testable import FundamentalStorage

@Suite("Staging and recovery resource ownership")
struct DocumentFileCandidateTests
{
    @Test("an unpublished candidate disappears with its owner")
    func ordinaryLifetime() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.location()
        var candidate: DocumentFileCandidate? = try DocumentFileCandidate(
            bytes: DocumentFileFixture.record, destination: location
        )
        let directory = try #require(candidate?.directory)
        let pending = try #require(candidate?.url)
        #expect(try Data(contentsOf: pending) == DocumentFileFixture.record)
        let attributes = try FileManager.default.attributesOfItem(
            atPath: pending.path
        )
        #expect((attributes[.posixPermissions] as? NSNumber)?.intValue == 0o600)
        candidate = nil
        #expect(!FileManager.default.fileExists(atPath: directory.path))
    }

    @Test("a reserved backup name cannot overwrite an occupied file")
    func backupCollision() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.location()
        let candidate = try DocumentFileCandidate(
            bytes: DocumentFileFixture.record, destination: location
        )
        let identity = UUID()
        let name = ".Fundamental-\(identity.uuidString)-Previous.fundamental"
        let occupied = try fixture.write(name: name)
        #expect(throws: (any Error).self)
        {
            try candidate.reserveBackup(at: location, identity: identity)
        }
        #expect(candidate.backupURL == nil)
        #expect(try Data(contentsOf: occupied.url) ==
            DocumentFileFixture.record)
    }

    @Test("one candidate cannot orphan an earlier backup reservation")
    func repeatedReservation() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.location()
        let candidate = try DocumentFileCandidate(
            bytes: DocumentFileFixture.record, destination: location
        )
        let backup = try candidate.reserveBackup(at: location)
        #expect(throws: DocumentFileFailure.destinationExists)
        {
            try candidate.reserveBackup(at: location)
        }
        #expect(candidate.backupURL == backup)
        #expect(candidate.discard().isEmpty)
        #expect(!FileManager.default.fileExists(atPath: backup.path))
    }
}
