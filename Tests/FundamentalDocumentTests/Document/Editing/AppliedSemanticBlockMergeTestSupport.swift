import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockMergeTests
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

    static func documentID(_ marker: UInt8) throws -> FundamentalDocumentID
    {
        try ResolvedDocumentPointTests.point(
            documentMarker: marker
        ).documentID
    }

    static func blockID(_ marker: UInt8) throws -> FundamentalBlockID
    {
        try ResolvedDocumentPointTests.point(
            blockMarker: marker
        ).blockID
    }

    static func request(
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        leadingMarker: UInt8 = 2,
        trailingMarker: UInt8 = 3
    ) throws -> SemanticBlockMerge?
    {
        SemanticBlockMerge(
            documentID: try documentID(documentMarker),
            revision: DocumentRevision(revision),
            leadingBlockID: try blockID(leadingMarker),
            trailingBlockID: try blockID(trailingMarker)
        )
    }

    static func apply(
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        leadingMarker: UInt8 = 2,
        trailingMarker: UInt8 = 3,
        in document: CanonicalDocument
    ) throws -> AppliedSemanticBlockMerge?
    {
        let candidate = try request(
            documentMarker: documentMarker,
            revision: revision,
            leadingMarker: leadingMarker,
            trailingMarker: trailingMarker
        )
        let merge = try #require(candidate)
        return AppliedSemanticBlockMerge(merge, in: document)
    }

    static func runs(
        in result: AppliedSemanticBlockMerge,
        at index: Int = 0
    ) throws -> [SemanticRun]
    {
        let block = result.document.content.blocks[index].block
        return try #require(EditableSemanticBlock(block)).runs
    }

    static func requireSendable<T: Sendable>(_ type: T.Type)
    {
    }
}
