import Foundation

struct SemanticBlockRecordCodec: Encodable
{
    private let block: SemanticBlock

    init(_ block: SemanticBlock)
    {
        self.block = block
    }

    static func encode(_ block: SemanticBlock) throws -> Data
    {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        var data = try encoder.encode(Self(block))
        data.append(0x0A)
        return data
    }

    static func decode(_ data: Data) throws -> SemanticBlock
    {
        try decodeRecord(
            SemanticTableRecordCodec.rootObject(from: data),
            path: []
        )
    }

    func encode(to encoder: Encoder) throws
    {
        try Self.encodeRecord(block, to: encoder)
    }
}
