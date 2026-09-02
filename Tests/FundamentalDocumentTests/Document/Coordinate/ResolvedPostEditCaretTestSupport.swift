import Testing

@testable import FundamentalDocument

extension ResolvedPostEditCaretTests
{
    static let affinities: [PostEditCaretAffinity] = [
        .preceding,
        .following
    ]

    static func document(
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blocks: [(marker: UInt8, block: SemanticBlock)]
    ) throws -> CanonicalDocument
    {
        try ResolvedDocumentPointTests.document(
            documentMarker: documentMarker,
            revision: revision,
            blocks: blocks
        )
    }

    static func point(
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2,
        offset: Int
    ) throws -> DocumentPoint
    {
        try ResolvedDocumentPointTests.point(
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: blockMarker,
            offset: offset
        )
    }

    static func paragraph(_ texts: [String]) -> SemanticBlock
    {
        ResolvedDocumentPointTests.paragraph(texts)
    }

    static func caretInFirstBlock(
        candidate offset: Int,
        affinity: PostEditCaretAffinity,
        in document: CanonicalDocument
    ) throws -> ResolvedPostEditCaret?
    {
        let candidate = DocumentPoint(
            documentID: document.documentID,
            revision: document.revision,
            blockID: document.content.firstBlock.blockID,
            utf16Offset: try ResolvedDocumentPointTests.offset(offset)
        )
        return ResolvedPostEditCaret(
            candidate: candidate,
            affinity: affinity,
            in: document
        )
    }

    static func resolvedOffsets(
        texts: [String],
        candidate: Int
    ) throws -> [Int]
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph(texts))
        ])
        return try resolvedOffsets(
            candidate: candidate,
            in: document
        )
    }

    static func resolvedOffsets(
        candidate: Int,
        in document: CanonicalDocument
    ) throws -> [Int]
    {
        try affinities.map
        {
            let result = try caretInFirstBlock(
                candidate: candidate,
                affinity: $0,
                in: document
            )
            let caret = try #require(result)
            return caret.resolvedPoint.point.utf16Offset.value
        }
    }
}
