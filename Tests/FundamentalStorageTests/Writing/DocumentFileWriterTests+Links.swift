import Darwin
import Foundation
import Testing

@testable import FundamentalStorage

extension DocumentFileWriterTests
{
    @Test("a substituted final link cannot redirect an owned save")
    func substitutedLink() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let other = try fixture.write(name: "Other.fundamental")
        let previous = try DocumentFileReader(
            location: location, codec: DocumentFileFixture.codec
        ).read()
        try FileManager.default.removeItem(at: location.url)
        try FileManager.default.createSymbolicLink(
            at: location.url, withDestinationURL: other.url
        )
        let update = try DocumentFileFixture.writer(
            at: location, condition: .unchanged(previous.revision)
        )
        #expect(throws: DocumentFileFailure.fileSystem(ELOOP))
        {
            try update.write()
        }
        let create = try DocumentFileFixture.writer(at: location)
        #expect(throws: DocumentFileFailure.destinationExists)
        {
            try create.write()
        }
        #expect(try Data(contentsOf: other.url) == DocumentFileFixture.record)
    }
}
