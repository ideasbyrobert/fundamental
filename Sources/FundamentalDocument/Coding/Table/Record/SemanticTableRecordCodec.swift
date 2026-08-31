import Foundation

struct SemanticTableRecordCodec: Encodable
{
    private let record: SemanticTableRecord

    private init(record: SemanticTableRecord)
    {
        self.record = record
    }

    static func decode(
        _ data: Data
    ) throws -> SemanticTableRecord
    {
        let object = try rootObject(from: data)
        guard object.keys.contains("record")
        else
        {
            return try decodeLegacy(data)
        }

        return try decodeRecord(object, path: [])
    }

    static func encode(
        _ record: SemanticTableRecord
    ) throws -> Data
    {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .sortedKeys,
            .withoutEscapingSlashes
        ]
        var data = try encoder.encode(Self(record: record))
        data.append(0x0A)
        return data
    }

    func encode(to encoder: Encoder) throws
    {
        try Self.encodeRecord(record, to: encoder)
    }
}
