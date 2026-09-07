import Foundation
import Testing

@testable import FundamentalStorage

extension DocumentFileWriterTests
{
    @Test("changed bytes or replacement identity refuse the old observation")
    func externalChanges() throws
    {
        let fixture = try DocumentFileFixture()
        for atomic in [false, true]
        {
            let location = try fixture.write(name: "\(atomic).fundamental")
            let previous = try DocumentFileReader(
                location: location, codec: DocumentFileFixture.codec
            ).read()
            let changed = try DocumentFileFixture.codec.encode(
                DocumentFileFixture.document("An outside edit.")
            )
            try changed.write(
                to: location.url, options: atomic ? .atomic : []
            )
            let writer = try DocumentFileFixture.writer(
                at: location, condition: .unchanged(previous.revision)
            )
            #expect(throws: DocumentFileFailure.conflictingRevision)
            {
                try writer.write()
            }
            #expect(try Data(contentsOf: location.url) == changed)
        }
    }

    @Test("exclusive rename refuses a file that appeared after preflight")
    func creationRace() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.location()
        let writer = try DocumentFileFixture.writer(at: location)
        let bytes = try DocumentFileFixture.codec.encode(writer.document)
        let candidate = try DocumentFileCandidate(
            bytes: bytes, destination: location
        )
        #expect(try writer.requirePriorState() == nil)
        _ = try fixture.write()
        #expect(throws: DocumentFileFailure.destinationExists)
        {
            try writer.publish(candidate, previous: nil, bytes: bytes)
        }
        #expect(!candidate.preserved)
        #expect(try Data(contentsOf: location.url) ==
            DocumentFileFixture.record)
        #expect(try Data(contentsOf: candidate.url) == bytes)
    }
}
