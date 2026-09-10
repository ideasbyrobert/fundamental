import Testing

@testable import FundamentalDocument

@MainActor
struct DocumentInputTestFixture
{
    let state: DocumentSessionState
    let edit: CanonicalDocumentEdit
    let destination: DocumentSnapshot
    let intent: DocumentTypingIntent

    init() throws
    {
        let source = try SemanticWritingTestDocument([.body], texts: ["AB"])
        let session = DocumentSession(state: try source.state())
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: .strong, enabled: true)
        ))
        state = session.state
        let insertion = try #require(SemanticInsertion(
            text: "e\u{301}😀", attributes: .direct(traits: [.emphasis])
        ))
        edit = .text(.insertion(SemanticTextInsertion(
            point: try source.point(0, 0), insertion: insertion
        )))
        let command = DocumentSessionCommand.edit(session.observation, edit)
        guard case let .applied(.editable(preview)) =
            DocumentSessionTransition(command, in: state)
        else
        {
            throw SessionTestFailure.expectedEditable
        }
        destination = preview.snapshot
        let link = try #require(SemanticLinkDestination(
            "https://a.test/e\u{301}"
        ))
        intent = DocumentTypingIntent(attributes: .scoped(
            traits: [.inlineCode], scopes: .link(link)
        ))
    }

    func selection(
        _ lower: Int, _ upper: Int? = nil
    ) throws -> DocumentSelection
    {
        let range = try #require(DocumentRange(start: point(lower),
                                               end: point(upper ?? lower)))
        return DocumentSelection(range: range)
    }

    func point(_ offset: Int) throws -> DocumentPoint
    {
        let document = destination.document
        return DocumentPoint(
            documentID: document.documentID, revision: document.revision,
            blockID: document.content.blocks[0].blockID,
            utf16Offset: try #require(DocumentUTF16Offset(offset))
        )
    }

    func command(
        _ selection: DocumentSelection, intent: DocumentTypingIntent? = nil
    ) -> DocumentSessionCommand
    {
        .input(DocumentObservation(snapshot: state.snapshot),
               DocumentInputTransaction(edit: edit, selection: selection,
                                         typingIntent: intent))
    }
}
