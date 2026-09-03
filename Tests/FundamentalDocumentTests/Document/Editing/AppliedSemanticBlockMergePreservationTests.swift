import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockMergeTests
{
    @Test("every adjacent position preserves unaffected neighbors")
    func everyAdjacentPositionPreservesUnaffectedNeighbors() throws
    {
        let markers: [UInt8] = [2, 4, 6, 8]
        let blocks = markers.map
        {
            ($0, Self.paragraph([SemanticRun(text: String($0))]))
        }
        for index in 0 ..< markers.count - 1
        {
            let source = try Self.document(blocks: blocks)
            let candidate = try Self.apply(
                leadingMarker: markers[index],
                trailingMarker: markers[index + 1],
                in: source
            )
            let result = try #require(candidate)
            let before = source.content.blocks
            let after = result.document.content.blocks

            #expect(after.map(\.blockID) == before.enumerated().compactMap
            {
                $0.offset == index + 1 ? nil : $0.element.blockID
            })
            #expect(result.caret.point.blockID == before[index].blockID)
            #expect(result.caret.blockIndex == index)
            #expect(result.caret.point.utf16Offset.value == 1)
            let resolved = try #require(ResolvedDocumentPoint(
                result.caret.point,
                in: result.document
            ))
            #expect(result.caret == resolved)
            for neighbor in before where
                neighbor.blockID != before[index].blockID &&
                neighbor.blockID != before[index + 1].blockID
            {
                #expect(after.contains(neighbor))
            }
        }
    }

    @Test("leading identity remains and trailing identity retires")
    func leadingIdentityRemainsAndTrailingIdentityRetires() throws
    {
        let block = Self.paragraph([SemanticRun(text: "A")])
        let source = try Self.document(blocks: [(2, block), (3, block)])
        let candidate = try Self.apply(in: source)
        let result = try #require(candidate)
        let ids = result.document.content.blocks.map(\.blockID)

        #expect(ids == [source.content.blocks[0].blockID])
        #expect(!ids.contains(source.content.blocks[1].blockID))
    }

    @Test("exact runs concatenate without a separator or coalescing")
    func exactRunsConcatenateWithoutSeparatorOrCoalescing() throws
    {
        let scopeValues = try SemanticRunAttributesTests.scopes()
        let scopes = try #require(scopeValues.last)
        let runs = [
            SemanticRun(
                text: "L",
                attributes: .scoped(traits: [.emphasis], scopes: scopes)
            ),
            SemanticRun(text: "A", traits: [.strong]),
            SemanticRun(text: "B", traits: [.strong]),
            SemanticRun(text: "", traits: [.inlineCode]),
            SemanticRun(text: "R", traits: [.emphasis])
        ]
        let source = try Self.document(blocks: [
            (2, Self.paragraph(Array(runs[0 ... 1]))),
            (3, Self.paragraph(Array(runs[2 ... 4])))
        ])
        let candidate = try Self.apply(in: source)
        let result = try #require(candidate)

        #expect(try Self.runs(in: result) == runs)
        #expect(try Self.runs(in: result).map(\.text).joined() == "LABR")
    }
}
