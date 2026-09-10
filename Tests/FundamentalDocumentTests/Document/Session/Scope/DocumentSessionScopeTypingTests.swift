import Testing

@testable import FundamentalDocument

@Suite("Scope typing intent belongs to the document session")
@MainActor
struct DocumentSessionScopeTypingTests
{
    @Test("scope choices change future typing without dirtying content",
          arguments: 0..<4)
    func assignment(operation: Int) throws
    {
        let original = try ScopeTestValue.attributes(
            link: ScopeTestValue.oldLink, language: ScopeTestValue.oldLanguage
        )
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [SemanticRun(
                text: "AB", attributes: original
            )]))
        ])
        let range = try source.range((0, 1), (0, 1))
        let session = DocumentSession(state: try source.state(range),
                                      initiallySaved: true)
        let pending = session.prepareSave()
        let assignment = try ScopeTestValue.assignments()[operation]
        guard case .applied = session.submit(.typingScope(
            session.observation, assignment
        ))
        else
        {
            Issue.record("Expected explicit scope typing intent")
            return
        }
        let targets: [(String?, String?)] = [
            (ScopeTestValue.newLink, ScopeTestValue.oldLanguage),
            (nil, ScopeTestValue.oldLanguage),
            (ScopeTestValue.oldLink, ScopeTestValue.newLanguage),
            (ScopeTestValue.oldLink, nil)
        ]
        let target = targets[operation]
        let expected = try ScopeTestValue.attributes(
            link: target.0, language: target.1
        )
        let state = try DocumentSessionTypingTests.editable(session)
        #expect(state.typingIntent?.attributes == expected)
        #expect(state.selection.range == range)
        #expect(state.snapshot.generation.value == 4)
        #expect(session.document == source.document)
        #expect(!session.canUndo && !session.canRedo && !session.isDirty)
        let before = session.current
        #expect(session.submit(.typingScope(session.observation, assignment)) ==
            .unchanged)
        #expect(session.current == before)
        #expect(session.acknowledgeSave(pending) && !session.isDirty)
    }
}
