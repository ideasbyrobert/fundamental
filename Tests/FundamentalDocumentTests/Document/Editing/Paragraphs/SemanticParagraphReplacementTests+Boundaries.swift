import Testing

@testable import FundamentalDocument

extension SemanticParagraphReplacementTests
{
    @Test("separators preserve empty leading and trailing paragraphs")
    func emptyParagraphs() throws
    {
        let source = try SessionTestDocument(texts: ["AB"])
        for offset in [0, 1, 2]
        {
            let edit = try request(
                in: source, from: (0, offset), to: (0, offset),
                text: ["", "", ""]
            )
            let result = try #require(AppliedSemanticParagraphReplacement(
                edit, in: source.editable.snapshot.document
            ))
            #expect(text(result.document) == [String("AB".prefix(offset)), "",
                                             String("AB".suffix(2 - offset))])
            #expect(result.caret.blockIndex == 2)
            #expect(result.caret.point.utf16Offset.value == 0)
        }
    }

    @Test("deleting all paragraph content retains one empty leading block")
    func deleteEverything() throws
    {
        let source = try SessionTestDocument(texts: ["AB", "", "CD"])
        let edit = try request(
            in: source, from: (0, 0), to: (2, 2), text: [""]
        )
        let result = try #require(AppliedSemanticParagraphReplacement(
            edit, in: source.editable.snapshot.document
        ))
        #expect(text(result.document) == [""])
        #expect(result.caret.blockIndex == 0)
        #expect(result.caret.point.utf16Offset.value == 0)
        #expect(result.document.content.blocks[0].blockID ==
            source.editable.snapshot.document.content.blocks[0].blockID)
    }

    @Test("joining a Unicode seam preserves scalars and resolves the caret")
    func unicodeSeam() throws
    {
        let source = try SessionTestDocument(texts: ["e", "\u{301}X"])
        let edit = try request(
            in: source, from: (0, 1), to: (1, 0), text: [""]
        )
        let result = try #require(AppliedSemanticParagraphReplacement(
            edit, in: source.editable.snapshot.document
        ))
        #expect(Array(text(result.document)[0].utf16) == [0x65, 0x301, 0x58])
        #expect(result.caret.point.utf16Offset.value == 0)
    }
}
