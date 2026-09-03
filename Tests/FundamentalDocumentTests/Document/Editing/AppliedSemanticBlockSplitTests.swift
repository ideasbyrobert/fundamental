import Testing

@testable import FundamentalDocument

@Suite("An applied semantic block split")
struct AppliedSemanticBlockSplitTests
{
    @Test("the intent preserves exact request facts and Sendable scope")
    func intentPreservesExactFactsAndSendableScope() throws
    {
        let point = try Self.point(offset: 1)
        let continuationID = try Self.blockID(7)
        let split = try #require(SemanticBlockSplit(
            point: point,
            continuationBlockID: continuationID
        ))

        #expect(split.point == point)
        #expect(split.continuationBlockID == continuationID)
        Self.requireSendable(SemanticBlockSplit.self)
        Self.requireSendable(AppliedSemanticBlockSplit.self)
    }

    @Test("equal source and continuation identities refuse")
    func equalSourceAndContinuationIdentitiesRefuse() throws
    {
        let point = try Self.point()
        let original = point

        #expect(SemanticBlockSplit(
            point: point,
            continuationBlockID: point.blockID
        ) == nil)
        #expect(point == original)
    }
}
