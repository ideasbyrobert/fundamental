import Testing

@testable import FundamentalDocument

extension SemanticListItemTests
{
    @Test("list replacement and deletion retain kind and Unicode caret")
    func replacementAndDeletion() throws
    {
        for style in [CanonicalBlockStyle.bulleted, .numbered]
        {
            let source = try SemanticWritingTestDocument(
                [style], texts: ["A😀B"]
            )
            let range = try source.range((0, 1), (0, 3))
            let insertion = try #require(SemanticInsertion(
                text: "e\u{301}", attributes: .direct(traits: [.strong])
            ))
            let edits: [SemanticTextEdit] = [
                .replacement(try #require(SemanticTextReplacement(
                    range: range, insertion: insertion
                ))),
                .deletion(try #require(SemanticTextDeletion(range: range)))
            ]
            for (index, edit) in edits.enumerated()
            {
                let result = try #require(AppliedSemanticTextEdit(
                    edit, in: source.document
                ))
                let block = result.document.content.blocks[0].block
                #expect(CanonicalBlockStyle(block) == style)
                #expect(SemanticWritingTestDocument.texts(result.document) ==
                    [index == 0 ? "Ae\u{301}B" : "AB"])
                #expect(result.caret.point.utf16Offset.value ==
                    (index == 0 ? 3 : 1))
            }
        }
    }

    @Test("explicit merge refuses incompatible list kinds")
    func incompatibleMerge() throws
    {
        let source = try SemanticWritingTestDocument([.bulleted, .numbered])
        let blocks = source.document.content.blocks
        let merge = try #require(SemanticBlockMerge(
            documentID: source.document.documentID,
            revision: source.document.revision,
            leadingBlockID: blocks[0].blockID,
            trailingBlockID: blocks[1].blockID
        ))
        #expect(AppliedSemanticBlockMerge(merge, in: source.document) == nil)
    }
}
