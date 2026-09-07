import Foundation

extension DocumentRecordCodec
{
    func decodeRoot(_ object: [String: Any]) throws -> CanonicalDocument
    {
        let reader = SemanticTableRecordCodec.self
        let format = try reader.string(
            reader.required("format", in: object, path: []),
            path: ["format"]
        )
        guard format == DocumentRecordEnvelope.format
        else
        {
            throw DocumentRecordFailure.unsupportedFormat
        }
        let version = try DocumentRecordUnsignedInteger.decode(
            reader.required("version", in: object, path: []),
            path: ["version"]
        )
        guard version == DocumentRecordEnvelope.version || version == 2
        else
        {
            throw DocumentRecordFailure.unsupportedVersion(version)
        }
        try reader.requireKeys(
            object,
            ["format", "version", "documentID", "revision", "blocks"],
            path: []
        )
        let identity = try Self.identity(
            reader.required("documentID", in: object, path: []),
            path: ["documentID"]
        )
        let revision = try DocumentRecordUnsignedInteger.decode(
            reader.required("revision", in: object, path: []),
            path: ["revision"]
        )
        let content = try decodeBlocks(
            reader.required("blocks", in: object, path: [])
        )
        if version == 1 && content.blocks.contains(where:
            { if case .listItem = $0.block { true } else { false } })
        {
            throw reader.invalid(["blocks"], "Lists require document version 2")
        }
        return CanonicalDocument(
            documentID: FundamentalDocumentID(identity),
            revision: DocumentRevision(revision),
            content: content
        )
    }

    static func identity(_ value: Any, path: [String]) throws -> UUID
    {
        let text = try SemanticTableRecordCodec.string(value, path: path)
        guard let identity = UUID(uuidString: text)
        else
        {
            throw SemanticTableRecordCodec.invalid(path, "Invalid identity")
        }
        return identity
    }
}
