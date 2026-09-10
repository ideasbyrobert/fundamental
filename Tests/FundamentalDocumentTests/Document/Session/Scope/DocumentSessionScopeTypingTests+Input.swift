import Testing

@testable import FundamentalDocument

extension DocumentSessionScopeTypingTests
{
    @Test("combined scopes survive typing Return and history")
    func inputHistory() throws
    {
        let source = try SemanticWritingTestDocument([.body], texts: [""])
        let session = DocumentSession(state: try source.state(),
                                      initiallySaved: true)
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: .strong, enabled: true)
        ))
        for index in [0, 2]
        {
            session.submit(.typingScope(session.observation,
                try ScopeTestValue.assignments()[index]))
        }
        let expected = try ScopeTestValue.attributes(
            link: ScopeTestValue.newLink, language: ScopeTestValue.newLanguage,
            traits: [.strong]
        )
        try DocumentSessionTypingTests.insert("e\u{301}😀", into: session)
        try DocumentSessionTypingTests.returnAtCaret(in: session)
        try DocumentSessionTypingTests.insert("X", into: session)
        CodeConversionTestValue.expectText(session.document, ["e\u{301}😀", "X"])
        for block in session.document.content.blocks
        {
            let runs = try CodeConversionTestValue.runs(block)
            #expect(runs.filter { !$0.text.isEmpty }.allSatisfy
                { $0.attributes == expected })
        }
        #expect(session.history.undo.count == 3)
        let changed = session.document.content
        for direction in [DocumentHistoryDirection.undo, .redo]
        {
            for _ in 0..<3
            {
                session.submit(DocumentHistoryCommand(
                    observation: session.observation, direction: direction
                ))
                let state = try DocumentSessionTypingTests.editable(session)
                #expect(state.typingIntent?.attributes == expected)
                #expect(state.selection.range.isCollapsed)
            }
            #expect(session.document.content ==
                (direction == .undo ? source.document.content : changed))
            #expect(session.isDirty == (direction == .redo))
        }
    }
}
