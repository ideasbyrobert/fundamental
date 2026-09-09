import Testing

@testable import FundamentalDocument

extension DocumentSessionCodeConversionTests
{
    @Test("converted meaning survives encoding and fresh document ownership")
    func persistence() throws
    {
        let source = try SemanticWritingTestDocument(
            [.title, .body], texts: ["e\u{301}", "\t😀"]
        )
        let session = DocumentSession(state: try source.state())
        let pending = session.prepareSave()
        let language = try #require(SemanticCodeLanguageIdentifier(" SwIfT "))
        let result = try session.submit(.convertCode(
            session.observation, SemanticCodeConversion(
                range: source.range((0, 0), (1, 3)), codeLanguage: language
            )
        ))
        guard case .applied = result
        else
        {
            Issue.record("Expected code creation")
            return
        }
        #expect(session.acknowledgeSave(pending))
        #expect(session.isDirty)
        let ticket = session.prepareSave()
        let codec = DocumentRecordCodec(limits: DocumentRecordLimits())
        let bytes = try codec.encode(ticket.document)
        #expect(try codec.encode(ticket.document) == bytes)
        let reopened = try codec.decode(bytes)
        #expect(reopened == ticket.document)
        let point = DocumentPoint(
            documentID: reopened.documentID, revision: reopened.revision,
            blockID: reopened.content.blocks[0].blockID,
            utf16Offset: try #require(DocumentUTF16Offset(0))
        )
        let owner = DocumentSession(state: .editable(try #require(
            EditableDocumentSnapshot(
                snapshot: DocumentSnapshot(
                    generation: SnapshotGeneration(0), document: reopened
                ),
                selection: .caret(at: point)
            )
        )), initiallySaved: true)
        #expect(!owner.canUndo && !owner.isDirty)
        CodeConversionTestValue.expectText(owner.document, ["e\u{301}\n\t😀"])
        guard case let .code(.languageTagged(code)) =
            owner.document.content.blocks[0].block
        else
        {
            Issue.record("Expected the persisted code language")
            return
        }
        #expect(code.language.value.utf16.elementsEqual(" SwIfT ".utf16))
    }
}
