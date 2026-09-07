import Foundation
import Testing

@testable import FundamentalStorage

extension DocumentFileReaderTests
{
    @Test("a complete record survives more than one filesystem read chunk")
    func multipleChunks() throws
    {
        let fixture = try DocumentFileFixture()
        var bytes = Data(repeating: 0x20, count: 65_535)
        bytes.append(DocumentFileFixture.record)
        let location = try fixture.write(bytes)
        let read = try DocumentFileReader(
            location: location, codec: DocumentFileFixture.codec
        ).read()
        #expect(read.revision.stamp.byteCount == bytes.count)
        let expected = try DocumentFileFixture.codec.decode(
            DocumentFileFixture.record
        )
        #expect(read.document == expected)
    }
}
