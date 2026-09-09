import Testing

@testable import FundamentalDocument

extension DocumentSessionInlineTests
{
    @Test("trait changes after a save ticket remain dirty and round trip")
    func persistence() throws
    {
        let scope = SemanticRunScopes.linkAndLanguage(
            link: try #require(SemanticLinkDestination("https://a.test/é")),
            language: try #require(SemanticLanguageIdentifier(" ru-RU "))
        )
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "Ae\u{301}😀Z", attributes: .scoped(
                    traits: [.emphasis], scopes: scope
                ))
            ]))
        ])
        let range = try source.range((0, 1), (0, 5))
        let session = DocumentSession(state: try source.state(range))
        let pending = session.prepareSave()
        guard case .applied = session.submit(.inline(session.observation,
            SemanticInlineTraitChange(range: range, trait: .strong,
                                      enabled: true)
        ))
        else
        {
            Issue.record("Expected formatting before saving")
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
        CodeConversionTestValue.expectText(reopened, ["Ae\u{301}😀Z"])
        let point = DocumentPoint(
            documentID: reopened.documentID, revision: reopened.revision,
            blockID: reopened.content.blocks[0].blockID,
            utf16Offset: try #require(DocumentUTF16Offset(0))
        )
        let owner = DocumentSession(state: .editable(try #require(
            EditableDocumentSnapshot(
                snapshot: DocumentSnapshot(
                    generation: SnapshotGeneration(0), document: reopened
                ), selection: .caret(at: point)
            )
        )), initiallySaved: true)
        #expect(!owner.canUndo && !owner.isDirty)
        #expect(owner.document.content == ticket.document.content)
        #expect(session.acknowledgeSave(ticket))
        #expect(!session.isDirty)
    }
}
