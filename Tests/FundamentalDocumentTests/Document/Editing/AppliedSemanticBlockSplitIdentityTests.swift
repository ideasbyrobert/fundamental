import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockSplitTests
{
    @Test("neighbors ordering and stable identities remain exact")
    func neighborsOrderingAndStableIdentitiesRemainExact() throws
    {
        let originalBlocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([SemanticRun(text: "First")])),
            (4, Self.paragraph([SemanticRun(text: "AB")])),
            (6, Self.plainCode([SemanticRun(text: "Last")]))
        ]
        let source = try Self.document(blocks: originalBlocks)
        let candidate = try Self.apply(
            at: 1,
            blockMarker: 4,
            continuationMarker: 5,
            in: source
        )
        let result = try #require(candidate)
        let before = source.content.blocks
        let after = result.document.content.blocks

        #expect(after.map(\.blockID) == [
            before[0].blockID,
            before[1].blockID,
            try Self.blockID(5),
            before[2].blockID
        ])
        #expect(after[0] == before[0])
        #expect(after[3] == before[2])
        #expect(result.document.documentID == source.documentID)
    }

    @Test("a continuation collision anywhere refuses atomically")
    func continuationCollisionAnywhereRefusesAtomically() throws
    {
        let target = Self.paragraph([SemanticRun(text: "AB")])
        let other = Self.paragraph([SemanticRun(text: "Other")])
        let cases: [[(UInt8, SemanticBlock)]] = [
            [(2, target), (7, other)],
            [(7, other), (2, target)]
        ]
        for blocks in cases
        {
            let source = try Self.document(blocks: blocks)
            let original = source

            #expect(try Self.apply(
                at: 1,
                continuationMarker: 7,
                in: source
            ) == nil)
            #expect(source == original)
        }
    }
}
