import Testing

@testable import FundamentalDocument

@Suite("An applied semantic text insertion")
struct AppliedSemanticTextEditTests
{
    @Test("beginning interior and end insert exact spelling")
    func positionsInsertExactSpelling() throws
    {
        let cases = [(0, "XAB"), (1, "AXB"), (2, "ABX")]
        for (offset, expected) in cases
        {
            let document = try Self.document(blocks: [
                (2, Self.paragraph([SemanticRun(text: "AB")]))
            ])
            let candidate = try Self.apply(
                text: "X",
                at: offset,
                in: document
            )
            let result = try #require(candidate)

            #expect(try Self.text(in: result) == expected)
        }

        let runless = try Self.document(blocks: [
            (2, Self.paragraph([]))
        ])
        let candidate = try Self.apply(
            text: "X",
            at: 0,
            in: runless
        )
        let result = try #require(candidate)
        #expect(try Self.text(in: result) == "X")
    }

    @Test("one success advances revision exactly once")
    func successAdvancesRevisionExactlyOnce() throws
    {
        let document = try Self.document(revision: 41, blocks: [
            (2, Self.paragraph([SemanticRun(text: "AB")]))
        ])
        let candidate = try Self.apply(
            text: "X",
            at: 1,
            revision: 41,
            in: document
        )
        let result = try #require(candidate)

        #expect(result.document.revision == DocumentRevision(42))
        #expect(result.caret.point.revision == DocumentRevision(42))
    }

    @Test("the source document remains unchanged")
    func sourceDocumentRemainsUnchanged() throws
    {
        let source = try Self.document(blocks: [
            (2, Self.paragraph([SemanticRun(text: "Original")]))
        ])
        let original = source
        let candidate = try Self.apply(
            text: "New",
            at: 0,
            in: source
        )
        let result = try #require(candidate)

        #expect(source == original)
        #expect(try Self.text(in: result) == "NewOriginal")
    }
}
