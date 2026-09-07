import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalStorage

extension DocumentFileWriterTests
{
    @Test("replacement preserves permissions and removes confirmed recovery")
    func replacement() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o640], ofItemAtPath: location.path
        )
        let previous = try DocumentFileReader(
            location: location, codec: DocumentFileFixture.codec
        ).read()
        let writer = try DocumentFileFixture.writer(
            at: location, condition: .unchanged(previous.revision)
        )
        let receipt = try writer.write()
        #expect(receipt.file.document == writer.document)
        #expect(receipt.file.revision != previous.revision)
        #expect(receipt.retainedItems.isEmpty)
        let attributes = try FileManager.default.attributesOfItem(
            atPath: location.path
        )
        #expect((attributes[.posixPermissions] as? NSNumber)?.intValue == 0o640)
        let names = try FileManager.default.contentsOfDirectory(
            atPath: fixture.root.path
        )
        #expect(names == [location.url.lastPathComponent])
    }

    @Test("a different canonical identity cannot claim an observed file")
    func foreignIdentity() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let previous = try DocumentFileReader(
            location: location, codec: DocumentFileFixture.codec
        ).read()
        let writer = DocumentFileWriter(
            document: try DocumentFileFixture.document(identity: UUID()),
            location: location,
            condition: .unchanged(previous.revision),
            codec: DocumentFileFixture.codec
        )
        #expect(throws: DocumentFileFailure.differentDocument)
        {
            try writer.write()
        }
        #expect(try Data(contentsOf: location.url) ==
            DocumentFileFixture.record)
    }
}
