import Testing

@testable import FundamentalDocument

extension DocumentSessionScopeTests
{
    @Test("scope spelling survives history and pending save tickets", arguments:
        [true, false])
    func spellingAndPersistence(linked: Bool) throws
    {
        let first = " é "
        let second = " e\u{301} "
        let initial = try ScopeTestValue.attributes(
            link: first, language: first
        )
        let expected = try ScopeTestValue.attributes(
            link: linked ? second : first, language: linked ? first : second
        )
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [SemanticRun(
                text: "Ae\u{301}😀Z", attributes: initial
            )]))
        ])
        let range = try source.range((0, 1), (0, 5))
        let session = DocumentSession(state: try source.state(range))
        let pending = session.prepareSave()
        let assignment: SemanticRunScopeAssignment = linked
            ? .link(try #require(SemanticLinkDestination(second)))
            : .language(try #require(SemanticLanguageIdentifier(second)))
        guard case .applied = session.submit(.scope(session.observation,
            SemanticRunScopeChange(range: range, assignment: assignment)
        ))
        else
        {
            Issue.record("Expected the spelling-only scope edit")
            return
        }
        #expect(session.acknowledgeSave(pending) && session.isDirty)
        let changed = session.document.content
        let expectedRuns = [
            SemanticRun(text: "A", attributes: initial),
            SemanticRun(text: "e\u{301}😀", attributes: expected),
            SemanticRun(text: "Z", attributes: initial)
        ]
        #expect(try CodeConversionTestValue.runs(
            changed.blocks[0]
        ) == expectedRuns)
        for direction in [DocumentHistoryDirection.undo, .redo]
        {
            session.submit(DocumentHistoryCommand(
                observation: session.observation, direction: direction
            ))
            #expect(session.document.content ==
                (direction == .undo ? source.document.content : changed))
        }
        let ticket = session.prepareSave()
        let codec = DocumentRecordCodec(limits: DocumentRecordLimits())
        let bytes = try codec.encode(ticket.document)
        #expect(try codec.encode(ticket.document) == bytes)
        let reopened = try codec.decode(bytes)
        #expect(reopened == ticket.document)
        #expect(try CodeConversionTestValue.runs(
            reopened.content.blocks[0]
        ) == expectedRuns)
        #expect(session.acknowledgeSave(ticket) && !session.isDirty)
    }
}
