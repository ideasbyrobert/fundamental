import Foundation
import Testing

@testable import FundamentalDocument

extension DocumentSessionTypingTests
{
    static func editable(_ session: DocumentSession) throws
        -> EditableDocumentSnapshot
    {
        guard case let .editable(value) = session.state
        else
        {
            throw SessionTestFailure.expectedEditable
        }
        return value
    }

    @discardableResult
    static func insert(_ text: String, into session: DocumentSession) throws
        -> DocumentSessionTransition
    {
        let state = try editable(session)
        let range = state.selection.range
        let attributes = try #require(state.typingAttributes(in: range))
        let insertion = try #require(SemanticInsertion(text: text,
                                                       attributes: attributes))
        return session.submit(.edit(session.observation, .text(.insertion(
            SemanticTextInsertion(point: range.start, insertion: insertion)
        ))))
    }

    @discardableResult
    static func returnAtCaret(in session: DocumentSession) throws
        -> DocumentSessionTransition
    {
        let range = try editable(session).selection.range
        let edit = try #require(SemanticParagraphReplacement(
            range: range, paragraphs: [SemanticParagraph(runs: []),
                                      SemanticParagraph(runs: [])],
            continuationBlockIDs: [FundamentalBlockID(UUID())]
        ))
        return session.submit(.edit(session.observation, .paragraphs(edit)))
    }
}
