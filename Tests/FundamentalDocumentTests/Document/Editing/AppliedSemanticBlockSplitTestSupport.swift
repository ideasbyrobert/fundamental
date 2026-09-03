import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockSplitTests
{
    static func document(
        revision: UInt64 = 8,
        blocks: [(UInt8, SemanticBlock)]
    ) throws -> CanonicalDocument
    {
        try ResolvedDocumentPointTests.document(
            revision: revision,
            blocks: blocks
        )
    }

    static func point(
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2,
        offset: Int = 0
    ) throws -> DocumentPoint
    {
        try ResolvedDocumentPointTests.point(
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: blockMarker,
            offset: offset
        )
    }

    static func blockID(_ marker: UInt8) throws -> FundamentalBlockID
    {
        try point(blockMarker: marker).blockID
    }

    static func request(
        at offset: Int,
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2,
        continuationMarker: UInt8 = 3
    ) throws -> SemanticBlockSplit?
    {
        SemanticBlockSplit(
            point: try point(
                documentMarker: documentMarker,
                revision: revision,
                blockMarker: blockMarker,
                offset: offset
            ),
            continuationBlockID: try blockID(continuationMarker)
        )
    }

    static func apply(
        at offset: Int,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2,
        continuationMarker: UInt8 = 3,
        in document: CanonicalDocument
    ) throws -> AppliedSemanticBlockSplit?
    {
        let candidate = try request(
            at: offset,
            revision: revision,
            blockMarker: blockMarker,
            continuationMarker: continuationMarker
        )
        let split = try #require(candidate)
        return AppliedSemanticBlockSplit(split, in: document)
    }

    static func requireSendable<T: Sendable>(_ type: T.Type)
    {
    }
}
