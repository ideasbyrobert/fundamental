import Testing

@testable import FundamentalDocument

@Suite("Atomic paragraph replacement")
struct SemanticParagraphReplacementTests
{
    @Test("spanning replacement retains outside blocks and leading identity")
    func spanningReplacement() throws
    {
        let source = try SessionTestDocument(texts: ["AB", "CD", "EF", "GH"])
        let edit = try request(
            in: source, from: (0, 1), to: (2, 1), text: ["X", "Y"]
        )
        let result = try #require(AppliedSemanticParagraphReplacement(
            edit, in: source.editable.snapshot.document
        ))
        #expect(text(result.document) == ["AX", "YF", "GH"])
        #expect(result.document.revision.value == 9)
        let before = source.editable.snapshot.document.content.blocks
        let after = result.document.content.blocks
        #expect(after[0].blockID == before[0].blockID)
        #expect(after[1].blockID == edit.continuationBlockIDs[0])
        #expect(after[2] == before[3])
        #expect(result.caret.point.blockID == after[1].blockID)
        #expect(result.caret.point.utf16Offset.value == 1)
        #expect(text(source.editable.snapshot.document) == ["AB", "CD", "EF",
                                                         "GH"])
    }

    @Test("reversed paragraph ranges produce the same ordered replacement")
    func reversedRange() throws
    {
        let source = try SessionTestDocument(texts: ["AB", "CD"])
        let forward = try request(
            in: source, from: (0, 1), to: (1, 1), text: ["X", ""]
        )
        let backward = try request(
            in: source, from: (1, 1), to: (0, 1), text: ["X", ""]
        )
        let document = source.editable.snapshot.document
        let result = try #require(AppliedSemanticParagraphReplacement(
            forward, in: document
        ))
        #expect(result == AppliedSemanticParagraphReplacement(
            backward, in: document
        ))
        #expect(text(result.document) == ["AX", "D"])
    }
}
