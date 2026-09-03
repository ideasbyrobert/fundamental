import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextDeletionTests
{
    @Test("whole spelling deletion leaves zero runs")
    func wholeSpellingDeletionLeavesZeroRuns() throws
    {
        let candidate = try Self.apply(
            start: 0,
            end: 4
        )
        let result = try #require(candidate)

        #expect(try Self.runs(in: result).isEmpty)
        #expect(result.caret.point.utf16Offset.value == 0)
    }

    @Test("every editable block form remains exact")
    func everyEditableBlockFormRemainsExact() throws
    {
        for (source, expected) in try Self.blockForms(
            sourceRuns: [SemanticRun(text: "AB")],
            expectedRuns: []
        )
        {
            let document = try Self.document(blocks: [(2, source)])
            let candidate = try Self.apply(
                start: 0,
                end: 2,
                in: document
            )
            let result = try #require(candidate)

            #expect(result.document.content.firstBlock.block == expected)
        }
    }

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
}
