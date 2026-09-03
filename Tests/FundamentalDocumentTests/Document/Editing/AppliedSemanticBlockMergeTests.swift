import Testing

@testable import FundamentalDocument

@Suite("An applied semantic block merge")
struct AppliedSemanticBlockMergeTests
{
    @Test("the intent preserves exact ordered facts and Sendable scope")
    func intentPreservesExactOrderedFactsAndSendableScope() throws
    {
        let documentID = try Self.documentID(1)
        let leadingID = try Self.blockID(2)
        let trailingID = try Self.blockID(3)
        let revision = DocumentRevision(8)
        let merge = try #require(SemanticBlockMerge(
            documentID: documentID,
            revision: revision,
            leadingBlockID: leadingID,
            trailingBlockID: trailingID
        ))

        #expect(merge.documentID == documentID)
        #expect(merge.revision == revision)
        #expect(merge.leadingBlockID == leadingID)
        #expect(merge.trailingBlockID == trailingID)
        Self.requireSendable(SemanticBlockMerge.self)
        Self.requireSendable(AppliedSemanticBlockMerge.self)
    }

    @Test("equal leading and trailing identities refuse")
    func equalLeadingAndTrailingIdentitiesRefuse() throws
    {
        let blockID = try Self.blockID(2)

        #expect(SemanticBlockMerge(
            documentID: try Self.documentID(1),
            revision: DocumentRevision(8),
            leadingBlockID: blockID,
            trailingBlockID: blockID
        ) == nil)
    }
}
