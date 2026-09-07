import Testing

@testable import FundamentalDocument

extension SemanticParagraphReplacementTests
{
    @Test("retained and inserted runs preserve their attributes and spelling")
    func runPreservation() throws
    {
        let fixture = try SessionTestDocument(texts: ["AB", "CD"])
        let original = fixture.editable.snapshot.document
        let language = try #require(SemanticLanguageIdentifier("fr"))
        let strong = SemanticRun(text: "AB", traits: [.strong])
        let scoped = try #require(SemanticInsertion(
            text: "CD", attributes: .scoped(
                traits: [], scopes: .language(language)
            )
        )).run
        let source = CanonicalDocument(
            documentID: original.documentID, revision: original.revision,
            content: try #require(CanonicalDocumentContent(
                firstBlock: IdentifiedSemanticBlock(
                    blockID: original.content.blocks[0].blockID,
                    block: .paragraph(SemanticParagraph(runs: [strong]))
                ),
                remainingBlocks: [IdentifiedSemanticBlock(
                    blockID: original.content.blocks[1].blockID,
                    block: .paragraph(SemanticParagraph(runs: [scoped]))
                )]
            ))
        )
        let plain = try request(
            in: fixture, from: (0, 1), to: (1, 1), text: ["e\u{301}", "😀"]
        )
        let inserted = SemanticRun(text: "e\u{301}", traits: [.emphasis])
        let edit = try #require(SemanticParagraphReplacement(
            range: plain.range,
            paragraphs: [SemanticParagraph(runs: [inserted]),
                         plain.paragraphs[1]],
            continuationBlockIDs: plain.continuationBlockIDs
        ))
        let result = try #require(AppliedSemanticParagraphReplacement(
            edit, in: source
        ))
        let first = try #require(EditableSemanticBlock(
            result.document.content.blocks[0].block
        )).runs
        let last = try #require(EditableSemanticBlock(
            result.document.content.blocks[1].block
        )).runs
        #expect(first == [SemanticRun(text: "A", traits: [.strong]), inserted])
        #expect(Array(first[1].text.utf16) == [0x65, 0x301])
        #expect(last[1].attributes == scoped.attributes)
        #expect(last[1].text == "D")
        #expect(result.caret.point.utf16Offset.value == 2)
    }

    @Test("prose replacement refuses to consume a code block")
    func nonParagraphRefusal() throws
    {
        let fixture = try SessionTestDocument(texts: ["A", "B"])
        let original = fixture.editable.snapshot.document
        let source = CanonicalDocument(
            documentID: original.documentID, revision: original.revision,
            content: try #require(CanonicalDocumentContent(
                firstBlock: original.content.blocks[0],
                remainingBlocks: [IdentifiedSemanticBlock(
                    blockID: original.content.blocks[1].blockID,
                    block: .code(.plain(PlainSemanticCodeBlock(runs: [
                        SemanticRun(text: "B")
                    ])))
                )]
            ))
        )
        let edit = try request(
            in: fixture, from: (0, 0), to: (1, 1), text: ["X"]
        )
        #expect(AppliedSemanticParagraphReplacement(edit, in: source) == nil)
    }
}
