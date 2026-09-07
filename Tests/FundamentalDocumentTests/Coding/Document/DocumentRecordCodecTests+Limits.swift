import Foundation
import Testing

@testable import FundamentalDocument

extension DocumentRecordCodecTests
{
    @Test("byte limits include the terminal newline and precede parsing")
    func exactByteBoundary() throws
    {
        let document = try DocumentRecordTestValue.plain()
        let bytes = try DocumentRecordTestValue.codec.encode(document)
        let exact = try #require(DocumentRecordLimits(
            maximumBytes: bytes.count,
            maximumBlocks: 1
        ))
        let short = try #require(DocumentRecordLimits(
            maximumBytes: bytes.count - 1,
            maximumBlocks: 1
        ))
        let codec = DocumentRecordCodec(limits: exact)
        #expect(try codec.encode(document) == bytes)
        #expect(try codec.decode(bytes) == document)
        let refusing = DocumentRecordCodec(limits: short)
        #expect(throws: DocumentRecordFailure.byteLimitExceeded)
        {
            try refusing.encode(document)
        }
        #expect(throws: DocumentRecordFailure.byteLimitExceeded)
        {
            try refusing.decode(Data(repeating: 0xFF, count: bytes.count))
        }
    }

    @Test("block limits refuse oversized input before decoding its members")
    func exactBlockBoundary() throws
    {
        let limits = try #require(DocumentRecordLimits(
            maximumBytes: 4096,
            maximumBlocks: 1
        ))
        let codec = DocumentRecordCodec(limits: limits)
        let document = try DocumentRecordTestValue.plain()
        #expect(try codec.decode(codec.encode(document)) == document)
        let excess = try DocumentRecordTestValue.document(blocks: [
            document.content.blocks[0].block,
            document.content.blocks[0].block
        ])
        #expect(throws: DocumentRecordFailure.blockLimitExceeded)
        {
            try codec.encode(excess)
        }
        var object = try DocumentRecordTestValue.object()
        object["blocks"] = [NSNull(), NSNull()]
        let bytes = try DocumentRecordTestValue.bytes(object)
        #expect(throws: DocumentRecordFailure.blockLimitExceeded)
        {
            try codec.decode(bytes)
        }
    }
}
