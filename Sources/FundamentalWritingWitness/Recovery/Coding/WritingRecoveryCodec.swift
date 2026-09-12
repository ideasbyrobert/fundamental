import Foundation
import FundamentalDocument

struct WritingRecoveryCodec: Sendable
{
    static let documentCodec = DocumentRecordCodec(
        limits: DocumentRecordLimits()
    )
    static let maximumBytes = documentCodec.limits.maximumBytes * 2 + 16_384

    func encode(_ record: WritingRecoveryRecord) throws -> Data
    {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        var data = try encoder.encode(WritingRecoveryEnvelope(record))
        data.append(0x0A)
        guard data.count <= Self.maximumBytes
        else
        {
            throw WritingRecoveryFailure.oversizedRecord
        }
        return data
    }

    func decode(_ data: Data) throws -> WritingRecoveryRecord
    {
        guard data.count <= Self.maximumBytes
        else
        {
            throw WritingRecoveryFailure.oversizedRecord
        }
        return try JSONDecoder().decode(WritingRecoveryEnvelope.self,
                                         from: data).record()
    }
}
