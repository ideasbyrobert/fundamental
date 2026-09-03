import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextReplacementTests
{
    @Test("neighbors order and stable identities remain exact")
    func neighborsOrderAndStableIdentitiesRemainExact() throws
    {
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([SemanticRun(text: "First")])),
            (7, Self.paragraph([SemanticRun(text: "ABCD")])),
            (9, Self.plainCode([SemanticRun(text: "Last")]))
        ]
        let source = try Self.document(blocks: blocks)
        let candidate = try Self.apply(
            start: 1,
            end: 3,
            blockMarker: 7,
            in: source
        )
        let result = try #require(candidate)
        let before = source.content.blocks
        let after = result.document.content.blocks

        #expect(after.map(\.blockID) == before.map(\.blockID))
        #expect(after[0] == before[0])
        #expect(after[2] == before[2])
        #expect(result.document.documentID == source.documentID)
    }

    @Test("equal-looking replacement still advances revision")
    func equalLookingReplacementStillAdvancesRevision() throws
    {
        let source = try Self.document(blocks: [
            (2, Self.paragraph([SemanticRun(text: "A")]))
        ])
        let candidate = try Self.apply(
            text: "A",
            start: 0,
            end: 1,
            in: source
        )
        let result = try #require(candidate)

        #expect(result.document.content == source.content)
        #expect(result.document.revision == DocumentRevision(9))
    }
}
