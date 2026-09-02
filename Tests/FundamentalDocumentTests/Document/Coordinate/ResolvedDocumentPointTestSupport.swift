import Foundation
import Testing

@testable import FundamentalDocument

extension ResolvedDocumentPointTests
{
    static func document(
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blocks: [(marker: UInt8, block: SemanticBlock)]
    ) throws -> CanonicalDocument
    {
        let identified = blocks.map
            {
                IdentifiedSemanticBlock(
                    blockID: FundamentalBlockID(uuid($0.marker)),
                    block: $0.block
                )
            }
        let first = try #require(identified.first)
        let content = try #require(CanonicalDocumentContent(
            firstBlock: first,
            remainingBlocks: Array(identified.dropFirst())
        ))
        return CanonicalDocument(
            documentID: FundamentalDocumentID(uuid(documentMarker)),
            revision: DocumentRevision(revision),
            content: content
        )
    }

    static func point(
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2,
        offset: Int = 0
    ) throws -> DocumentPoint
    {
        DocumentPoint(
            documentID: FundamentalDocumentID(uuid(documentMarker)),
            revision: DocumentRevision(revision),
            blockID: FundamentalBlockID(uuid(blockMarker)),
            utf16Offset: try Self.offset(offset)
        )
    }

    static func paragraph(_ texts: [String]) -> SemanticBlock
    {
        .paragraph(SemanticParagraph(
            runs: texts.map { SemanticRun(text: $0) }
        ))
    }

    static func offset(_ value: Int) throws -> DocumentUTF16Offset
    {
        try #require(DocumentUTF16Offset(value))
    }

    private static func uuid(_ marker: UInt8) -> UUID
    {
        UUID(uuid: (marker, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    }
}
