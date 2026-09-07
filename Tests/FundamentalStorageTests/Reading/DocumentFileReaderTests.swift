import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalStorage

@Suite("Complete bounded file reads")
struct DocumentFileReaderTests
{
    @Test("a read preserves canonical identity revision and raw Unicode")
    func completeDocument() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let read = try DocumentFileReader(
            location: location,
            codec: DocumentFileFixture.codec
        ).read()
        #expect(read.location == location)
        #expect(read.document.documentID.value ==
            UUID(uuidString: "00000000-0000-0000-0000-000000000001"))
        #expect(read.document.revision.value == 9_007_199_254_740_993)
        let block = try #require(read.document.content.blocks.first)
        guard case let .paragraph(paragraph) = block.block
        else
        {
            Issue.record("The admitted paragraph changed its canonical kind.")
            return
        }
        let text = paragraph.runs.map(\.text).joined()
        #expect(Array(text.utf8) == Array("e\u{301} Հայ 👩‍💻".utf8))
        #expect(read.revision.stamp.byteCount ==
            DocumentFileFixture.record.count)
    }

    @Test("an exact byte bound includes every admitted input byte")
    func byteBound() throws
    {
        let fixture = try DocumentFileFixture()
        let location = try fixture.write()
        let count = DocumentFileFixture.record.count
        let limits = try #require(DocumentRecordLimits(
            maximumBytes: count, maximumBlocks: 1
        ))
        let codec = DocumentRecordCodec(limits: limits)
        _ = try DocumentFileReader(location: location, codec: codec).read()
        let smaller = try #require(DocumentRecordLimits(
            maximumBytes: count - 1, maximumBlocks: 1
        ))
        #expect(throws: DocumentRecordFailure.byteLimitExceeded)
        {
            try DocumentFileReader(
                location: location, codec: DocumentRecordCodec(limits: smaller)
            ).read()
        }
    }

    @Test("malformed and empty files cannot publish partial documents")
    func invalidRecords() throws
    {
        let fixture = try DocumentFileFixture()
        for (index, bytes) in [Data(), Data("{".utf8)].enumerated()
        {
            let location = try fixture.write(
                bytes, name: "\(index).fundamental"
            )
            #expect(throws: (any Error).self)
            {
                try DocumentFileReader(
                    location: location, codec: DocumentFileFixture.codec
                ).read()
            }
        }
    }
}
