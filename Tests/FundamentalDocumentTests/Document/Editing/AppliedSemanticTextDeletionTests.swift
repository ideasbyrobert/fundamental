import Testing

@testable import FundamentalDocument

@Suite("An applied semantic text deletion")
struct AppliedSemanticTextDeletionTests
{
    @Test("forward and reverse ranges remove the same scalar interval")
    func rangeDirectionDoesNotChangeDeletion() throws
    {
        for bounds in [(1, 3), (3, 1)]
        {
            let candidate = try Self.apply(
                start: bounds.0,
                end: bounds.1
            )
            let result = try #require(candidate)

            #expect(try Self.text(in: result) == "AD")
            #expect(result.caret.point.utf16Offset.value == 1)
        }
    }

    @Test("one success advances revision exactly once")
    func successAdvancesRevisionExactlyOnce() throws
    {
        let document = try Self.document(revision: 41, blocks: [
            (2, Self.paragraph([SemanticRun(text: "ABCD")]))
        ])
        let candidate = try Self.apply(
            start: 1,
            end: 3,
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
            start: 0,
            end: 3,
            in: source
        )
        let result = try #require(candidate)

        #expect(source == original)
        #expect(try Self.text(in: result) == "ginal")
    }
}
