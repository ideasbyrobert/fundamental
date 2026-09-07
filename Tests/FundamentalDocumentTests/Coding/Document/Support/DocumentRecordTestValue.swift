import Foundation
import Testing

@testable import FundamentalDocument

struct DocumentRecordTestValue
{
    static let codec = DocumentRecordCodec(limits: DocumentRecordLimits())

    static func document(
        blocks: [SemanticBlock],
        revision: UInt64 = 8
    ) throws -> CanonicalDocument
    {
        let identified = blocks.enumerated().map
        {
            IdentifiedSemanticBlock(
                blockID: FundamentalBlockID(identity(UInt8($0.offset + 2))),
                block: $0.element
            )
        }
        let first = try #require(identified.first)
        let content = try #require(CanonicalDocumentContent(
            firstBlock: first,
            remainingBlocks: Array(identified.dropFirst())
        ))
        return CanonicalDocument(
            documentID: FundamentalDocumentID(identity(1)),
            revision: DocumentRevision(revision),
            content: content
        )
    }

    static func plain() throws -> CanonicalDocument
    {
        try document(blocks: [
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: "A")]))
        ])
    }

    static func object() throws -> [String: Any]
    {
        let bytes = try codec.encode(plain())
        return try #require(
            JSONSerialization.jsonObject(with: bytes) as? [String: Any]
        )
    }

    static func bytes(_ object: [String: Any]) throws -> Data
    {
        try JSONSerialization.data(withJSONObject: object, options: .sortedKeys)
    }

    static func identity(_ marker: UInt8) -> UUID
    {
        UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, marker))
    }
}
