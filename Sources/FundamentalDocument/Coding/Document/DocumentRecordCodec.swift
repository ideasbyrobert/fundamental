import Foundation

package struct DocumentRecordCodec: Sendable
{
    package let limits: DocumentRecordLimits

    package init(limits: DocumentRecordLimits)
    {
        self.limits = limits
    }

    package func encode(_ document: CanonicalDocument) throws -> Data
    {
        guard document.content.blocks.count <= limits.maximumBlocks
        else
        {
            throw DocumentRecordFailure.blockLimitExceeded
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .withoutEscapingSlashes]
        var data = try encoder.encode(DocumentRecordEnvelope(document))
        data.append(0x0A)
        guard data.count <= limits.maximumBytes
        else
        {
            throw DocumentRecordFailure.byteLimitExceeded
        }
        return data
    }

    package func decode(_ data: Data) throws -> CanonicalDocument
    {
        guard data.count <= limits.maximumBytes
        else
        {
            throw DocumentRecordFailure.byteLimitExceeded
        }
        return try decodeRoot(SemanticTableRecordCodec.rootObject(from: data))
    }
}
