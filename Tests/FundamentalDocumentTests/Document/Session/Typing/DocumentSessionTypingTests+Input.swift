import Testing

@testable import FundamentalDocument

extension DocumentSessionTypingTests
{
    @Test("typing Return and history retain every explicit trait", arguments:
        AppliedSemanticInlineTraitChangeTests.traits)
    func inputHistory(trait: SemanticInlineTrait) throws
    {
        let source = try SemanticWritingTestDocument([.body], texts: [""])
        let session = DocumentSession(state: try source.state(),
                                      initiallySaved: true)
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: trait, enabled: true)
        ))
        try Self.insert("e\u{301}😀", into: session)
        try Self.returnAtCaret(in: session)
        try Self.insert("X", into: session)
        CodeConversionTestValue.expectText(session.document, ["e\u{301}😀", "X"])
        for block in session.document.content.blocks
        {
            let runs = try CodeConversionTestValue.runs(block)
            #expect(runs.filter { !$0.text.isEmpty }.allSatisfy
                { $0.traits == [trait] })
        }
        let allRuns = try session.document.content.blocks.flatMap
        {
            try CodeConversionTestValue.runs($0)
        }
        #expect(allRuns.filter { $0.text.isEmpty } == [SemanticRun(text: "")])
        #expect(session.history.undo.count == 3)
        let changed = session.document.content
        for direction in [DocumentHistoryDirection.undo, .redo]
        {
            for _ in 0 ..< 3
            {
                session.submit(DocumentHistoryCommand(
                    observation: session.observation, direction: direction
                ))
                let state = try Self.editable(session)
                #expect(state.typingIntent?.attributes ==
                    .direct(traits: [trait]))
                #expect(state.selection.range.isCollapsed)
            }
            #expect(session.document.content ==
                (direction == .undo ? source.document.content : changed))
            #expect(session.isDirty == (direction == .redo))
        }
    }

    @Test("an explicit source payload determines the following typing context")
    func explicitPayload() throws
    {
        let source = try SemanticWritingTestDocument([.body], texts: [""])
        let session = DocumentSession(state: try source.state())
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: .strong, enabled: true)
        ))
        let insertion = try #require(SemanticInsertion(
            text: "X", attributes: .direct(traits: [.emphasis])
        ))
        session.submit(.edit(session.observation, .text(.insertion(
            SemanticTextInsertion(point: try source.point(0, 0),
                                  insertion: insertion)
        ))))
        #expect(try Self.editable(session).typingIntent?.attributes ==
            .direct(traits: [.emphasis]))
        #expect(try CodeConversionTestValue.runs(
            session.document.content.blocks[0]
        ) == [SemanticRun(text: "X", traits: [.emphasis]),
              SemanticRun(text: "")])
    }
}
