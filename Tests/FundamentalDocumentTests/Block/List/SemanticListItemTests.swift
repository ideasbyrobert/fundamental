import Testing

@testable import FundamentalDocument

@Suite("List items retain text independently of their markers")
struct SemanticListItemTests
{
    @Test("editing splitting and merging preserve both list kinds")
    func editSplitMerge() throws
    {
        for style in [CanonicalBlockStyle.bulleted, .numbered]
        {
            let source = try SemanticWritingTestDocument(
                [style], texts: ["A😀B"]
            )
            let point = try source.point(0, 1)
            let insertion = try SessionTestEdit.inserted("e\u{301}", at: point)
            let edited = try #require(AppliedCanonicalDocumentEdit(
                insertion, in: source.document
            ))
            #expect(CanonicalBlockStyle(edited.document.content.blocks[0].block)
                == style)
            #expect(SemanticWritingTestDocument.texts(edited.document) ==
                ["Ae\u{301}😀B"])
            let split = try #require(SemanticBlockSplit(
                point: point, continuationBlockID: FundamentalBlockID(
                    SessionTestDocument.identity(99)
                )
            ))
            let divided = try #require(AppliedSemanticBlockSplit(
                split, in: source.document
            ))
            #expect(SemanticWritingTestDocument.texts(divided.document) ==
                ["A", "😀B"])
            #expect(divided.document.content.blocks.allSatisfy
                { CanonicalBlockStyle($0.block) == style })
            let merge = try #require(SemanticBlockMerge(
                documentID: divided.document.documentID,
                revision: divided.document.revision,
                leadingBlockID: source.document.content.blocks[0].blockID,
                trailingBlockID: split.continuationBlockID
            ))
            let joined = try #require(AppliedSemanticBlockMerge(
                merge, in: divided.document
            ))
            let block = try #require(joined.document.content.blocks.first)
            #expect(block.blockID == source.document.content.blocks[0].blockID)
            #expect(CanonicalBlockStyle(block.block) == style)
            #expect(SemanticWritingTestDocument.texts(joined.document) ==
                ["A😀B"])
            #expect(EditableSemanticBlock(block.block)?.runs ==
                [SemanticRun(text: "A"), SemanticRun(text: "😀B")])
            #expect(joined.caret.point.utf16Offset.value == 1)
        }
    }

    @Test("list edits refuse separators and split graphemes")
    func boundaryRefusal() throws
    {
        let source = try SemanticWritingTestDocument([.numbered], texts: ["😀"])
        for (text, offset) in [("\n", 0), ("\r", 0), ("X", 1)]
        {
            let edit = try SessionTestEdit.inserted(
                text, at: source.point(0, offset)
            )
            #expect(AppliedCanonicalDocumentEdit(edit, in: source.document)
                == nil)
        }
    }
}
