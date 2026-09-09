import Testing

@testable import FundamentalDocument

extension SemanticParagraphReplacementTests
{
    @MainActor
    @Test(arguments: [1, 3, 9])
    func mixedCodeReplacementRefusesInvalidSourceBoundaries(offset: Int)
        throws
    {
        let source = try SemanticWritingTestDocument(
            [.body, .monostyled], texts: ["A", "😀\r\nB"]
        )
        let session = DocumentSession(
            state: try source.state(), initiallySaved: true
        )
        let before = DocumentSessionStorage(
            state: session.state, history: session.history
        )
        let edit = try source.replacement((0, 1), (1, offset), text: ["X"])
        #expect(session.submit(.edit(session.observation, .paragraphs(edit)))
            == .refused(.invalidCommand))
        #expect(DocumentSessionStorage(state: session.state,
            history: session.history) == before)
        #expect(!session.isDirty)
    }

    @Test
    func mixedCodeReplacementRefusesTablesAndExhaustedRevision() throws
    {
        let source = try SemanticWritingTestDocument(
            [.body, .monostyled], revision: UInt64.max
        )
        #expect(AppliedSemanticParagraphReplacement(
            try source.replacement((0, 1), (1, 1), text: ["X"]),
            in: source.document
        ) == nil)
        let content = try #require(SemanticTableContent(
            headerRows: [], bodyRows: [], columnAlignments: []
        ))
        let table = SemanticBlock.table(.semantic(.regular(
            RegularSemanticTable(content: content)
        )))
        let guarded = try SemanticWritingTestDocument(blocks: [
            CanonicalBlockStyle.body.semanticBlock(runs: [
                SemanticRun(text: "A")
            ]),
            table,
            CanonicalBlockStyle.monostyled.semanticBlock(runs: [
                SemanticRun(text: "B")
            ])
        ])
        #expect(AppliedSemanticParagraphReplacement(
            try guarded.replacement((0, 1), (2, 1), text: ["X"]),
            in: guarded.document
        ) == nil)
    }
}
