import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextDeletionTests
{
    static func document(
        revision: UInt64 = 8,
        blocks: [(UInt8, SemanticBlock)]
    ) throws -> CanonicalDocument
    {
        try AppliedSemanticTextEditTests.document(
            revision: revision,
            blocks: blocks
        )
    }

    static func deletion(
        start: Int,
        end: Int,
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2
    ) throws -> SemanticTextDeletion
    {
        let startPoint = try ResolvedDocumentPointTests.point(
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: blockMarker,
            offset: start
        )
        let endPoint = try ResolvedDocumentPointTests.point(
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: blockMarker,
            offset: end
        )
        let range = try #require(DocumentRange(
            start: startPoint,
            end: endPoint
        ))
        return try #require(SemanticTextDeletion(range: range))
    }

    static func apply(
        start: Int,
        end: Int,
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2,
        blocks: [(UInt8, SemanticBlock)]? = nil
    ) throws -> AppliedSemanticTextEdit?
    {
        let sourceBlocks: [(UInt8, SemanticBlock)]
        if let blocks
        {
            sourceBlocks = blocks
        }
        else
        {
            sourceBlocks = [
                (2, paragraph([SemanticRun(text: "ABCD")]))
            ]
        }
        let document = try Self.document(
            revision: revision,
            blocks: sourceBlocks
        )
        return try apply(
            start: start,
            end: end,
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: blockMarker,
            in: document
        )
    }

    static func apply(
        start: Int,
        end: Int,
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2,
        in document: CanonicalDocument
    ) throws -> AppliedSemanticTextEdit?
    {
        let deletion = try Self.deletion(
            start: start,
            end: end,
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: blockMarker
        )
        return AppliedSemanticTextEdit(deletion, in: document)
    }
}
