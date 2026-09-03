import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextEditTests
{
    @Test("every inserted attribute form remains exact")
    func everyInsertedAttributeFormRemainsExact() throws
    {
        let scopes = try SemanticRunAttributesTests.scopes()
        let attributes: [SemanticRunAttributes] = [
            .direct(traits: [.strong])
        ] + scopes.map { .scoped(traits: [.emphasis], scopes: $0) }

        for attribute in attributes
        {
            let candidate = try Self.apply(
                text: "X",
                attributes: attribute,
                at: 1
            )
            let result = try #require(candidate)
            let runs = try Self.runs(in: result)
            #expect(runs[1].attributes == attribute)
        }
    }

    @Test("every editable block form remains exact")
    func everyEditableBlockFormRemainsExact() throws
    {
        let expectedRuns = [
            SemanticRun(text: "A"),
            SemanticRun(text: "X"),
            SemanticRun(text: "B")
        ]
        for (source, expected) in try Self.blockForms(
            sourceRuns: [SemanticRun(text: "AB")],
            expectedRuns: expectedRuns
        )
        {
            let document = try Self.document(blocks: [(2, source)])
            let candidate = try Self.apply(
                text: "X",
                at: 1,
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
            (7, Self.paragraph([SemanticRun(text: "AB")])),
            (9, Self.plainCode([SemanticRun(text: "Last")]))
        ]
        let source = try Self.document(blocks: blocks)
        let candidate = try Self.apply(
            text: "X",
            at: 1,
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
