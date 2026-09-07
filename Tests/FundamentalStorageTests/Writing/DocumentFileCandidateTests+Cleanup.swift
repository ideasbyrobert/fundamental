import Darwin
import Foundation
import Testing

@testable import FundamentalStorage

extension DocumentFileCandidateTests
{
    @Test("cleanup failure reports the retained item without losing its bytes",
          .enabled(if: geteuid() != 0))
    func refusedCleanup() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.location()
        let candidate = try DocumentFileCandidate(
            bytes: DocumentFileFixture.record, destination: location
        )
        let backup = try candidate.reserveBackup(at: location)
        try DocumentFileFixture.record.write(to: backup)
        #expect(chmod(fixture.root.path, 0o500) == 0)
        defer
        {
            _ = chmod(fixture.root.path, 0o700)
        }
        #expect(candidate.discard() == [backup])
        #expect(try Data(contentsOf: backup) == DocumentFileFixture.record)
        #expect(!FileManager.default.fileExists(
            atPath: candidate.directory.path
        ))
    }
}
