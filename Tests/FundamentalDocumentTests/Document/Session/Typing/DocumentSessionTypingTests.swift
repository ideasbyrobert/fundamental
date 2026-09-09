import Testing

@testable import FundamentalDocument

@Suite("Typing intent belongs to the document session")
@MainActor
struct DocumentSessionTypingTests
{
    @Test("each explicit trait changes only typing state", arguments:
        AppliedSemanticInlineTraitChangeTests.traits)
    func assignment(trait: SemanticInlineTrait) throws
    {
        let source = try SemanticWritingTestDocument([.body])
        let range = try source.range((0, 1), (0, 1))
        let session = DocumentSession(state: try source.state(range),
                                      initiallySaved: true)
        let pending = session.prepareSave()
        let command = SemanticInlineTraitAssignment(trait: trait, enabled: true)
        guard case .applied = session.submit(.typing(session.observation,
                                                     command))
        else
        {
            Issue.record("Expected explicit typing intent")
            return
        }
        let state = try Self.editable(session)
        #expect(state.typingIntent == DocumentTypingIntent(
            attributes: .direct(traits: [trait])
        ))
        #expect(state.selection.range == range)
        #expect(state.snapshot.generation.value == 4)
        #expect(session.document == source.document)
        #expect(!session.canUndo && !session.canRedo && !session.isDirty)
        let before = session.current
        #expect(session.submit(.typing(session.observation, command)) ==
            .unchanged)
        #expect(session.current == before)
        #expect(session.acknowledgeSave(pending))
        #expect(!session.isDirty)
    }

    @Test("typing exclusivity preserves exact scopes and unrelated traits")
    func scopes() throws
    {
        let scope = SemanticRunScopes.linkAndLanguage(
            link: try #require(SemanticLinkDestination("https://a.test/é")),
            language: try #require(SemanticLanguageIdentifier(" ru-RU "))
        )
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "A", attributes: .scoped(
                    traits: [.subscriptText, .strong], scopes: scope
                ))
            ]))
        ])
        let session = DocumentSession(state: try source.state())
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: .superscript, enabled: true)
        ))
        #expect(try Self.editable(session).typingIntent?.attributes == .scoped(
            traits: [.strong, .superscript], scopes: scope
        ))
        #expect(session.document == source.document)
    }
}
