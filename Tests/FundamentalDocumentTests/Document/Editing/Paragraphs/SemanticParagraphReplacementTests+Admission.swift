import Testing

@testable import FundamentalDocument

extension SemanticParagraphReplacementTests
{
    @Test("paragraph requests refuse malformed shape")
    func requestAdmission() throws
    {
        let source = try SessionTestDocument()
        let range = try source.selection(1, 2).range
        let empty = SemanticParagraph(runs: [])
        let identifier = FundamentalBlockID(SessionTestDocument.identity(100))
        #expect(SemanticParagraphReplacement(
            range: range, paragraphs: [], continuationBlockIDs: []
        ) == nil)
        #expect(SemanticParagraphReplacement(
            range: range, paragraphs: [empty, empty], continuationBlockIDs: []
        ) == nil)
        #expect(SemanticParagraphReplacement(
            range: range, paragraphs: [empty, empty, empty],
            continuationBlockIDs: [identifier, identifier]
        ) == nil)
        #expect(SemanticParagraphReplacement(
            range: try source.selection(0, 0).range,
            paragraphs: [empty], continuationBlockIDs: []
        ) == nil)
    }

    @Test("paragraph replacements refuse occupied continuation identities")
    func occupiedIdentity() throws
    {
        let source = try SessionTestDocument()
        let document = source.editable.snapshot.document
        let empty = SemanticParagraph(runs: [])
        for block in document.content.blocks
        {
            let edit = try #require(SemanticParagraphReplacement(
                range: source.selection(1, 1).range,
                paragraphs: [empty, empty],
                continuationBlockIDs: [block.blockID]
            ))
            #expect(AppliedSemanticParagraphReplacement(edit, in: document)
                == nil)
        }
    }

    @Test("stale and exhausted paragraph edits cannot publish a successor")
    func staleAndExhausted() throws
    {
        for revision in [UInt64(8), UInt64.max]
        {
            let source = try SessionTestDocument(revision: revision)
            let edit = try request(
                in: source, from: (0, 1), to: (1, 1), text: ["X"]
            )
            let target = revision == 8 ? try SessionTestDocument(revision: 9) :
                source
            #expect(AppliedSemanticParagraphReplacement(
                edit, in: target.editable.snapshot.document
            ) == nil)
        }
    }
}
