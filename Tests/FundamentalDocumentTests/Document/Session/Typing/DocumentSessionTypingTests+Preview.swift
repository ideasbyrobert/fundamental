import Foundation
import Testing

@testable import FundamentalDocument

extension DocumentSessionTypingTests
{
    @Test("a provisional transition retains intent without publishing history")
    func preview() throws
    {
        let source = try SemanticWritingTestDocument([.body], texts: [""])
        let session = DocumentSession(state: try source.state(),
                                      initiallySaved: true)
        session.submit(.typing(session.observation,
            SemanticInlineTraitAssignment(trait: .strong, enabled: true)
        ))
        let before = session.current
        let range = try Self.editable(session).selection.range
        let replacement = try #require(SemanticParagraphReplacement(
            range: range, paragraphs: [SemanticParagraph(runs: []),
                                      SemanticParagraph(runs: [])],
            continuationBlockIDs: [FundamentalBlockID(UUID())]
        ))
        let command = DocumentSessionCommand.edit(session.observation,
                                                  .paragraphs(replacement))
        guard case let .applied(.editable(preview)) =
            DocumentSessionTransition(command, in: session.state)
        else
        {
            Issue.record("Expected an immutable provisional transition")
            return
        }
        #expect(preview.typingIntent?.attributes == .direct(traits: [.strong]))
        #expect(preview.snapshot.document.content.blocks.count == 2)
        #expect(session.current == before && !session.isDirty)
        #expect(!session.canUndo)
        session.submit(command)
        #expect(session.history.undo.count == 1)
        #expect(try Self.editable(session) == preview)
        #expect(session.isDirty)
    }
}
