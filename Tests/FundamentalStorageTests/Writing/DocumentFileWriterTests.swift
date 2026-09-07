import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalStorage

@Suite("Conditional complete document publication")
struct DocumentFileWriterTests
{
    @Test("exclusive creation installs complete bytes and a fresh receipt")
    func createDocument() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.location()
        let writer = try DocumentFileFixture.writer(at: location)
        let receipt = try writer.write()
        let expected = try DocumentFileFixture.codec.encode(writer.document)
        #expect(try Data(contentsOf: location.url) == expected)
        #expect(receipt.file.document == writer.document)
        #expect(receipt.file.location == location)
        #expect(receipt.retainedItems.isEmpty)
        let reopened = try DocumentFileReader(
            location: location, codec: DocumentFileFixture.codec
        ).read()
        #expect(receipt.file.revision == reopened.revision)
    }

    @Test("an occupied new destination retains all its original bytes")
    func occupiedDestination() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let writer = try DocumentFileFixture.writer(at: location)
        #expect(throws: DocumentFileFailure.destinationExists)
        {
            try writer.write()
        }
        #expect(try Data(contentsOf: location.url) ==
            DocumentFileFixture.record)
    }

    @Test("encoding refusal never creates the destination")
    func oversizedOutput() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.location()
        let limits = try #require(DocumentRecordLimits(
            maximumBytes: 1, maximumBlocks: 1
        ))
        let writer = DocumentFileWriter(
            document: try DocumentFileFixture.document(),
            location: location,
            condition: .absent,
            codec: DocumentRecordCodec(limits: limits)
        )
        #expect(throws: DocumentRecordFailure.byteLimitExceeded)
        {
            try writer.write()
        }
        #expect(!FileManager.default.fileExists(atPath: location.path))
    }
}
