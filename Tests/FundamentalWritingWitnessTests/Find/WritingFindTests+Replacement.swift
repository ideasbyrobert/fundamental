import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingFindTests
{
    @Test("matches across styled runs become one canonical replacement action")
    func styledReplacement() throws
    {
        let tail = SemanticRun(text: " tail", traits: [.underline])
        let source = try WritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "ca", traits: [.strong]),
                SemanticRun(text: "fé", traits: [.emphasis]), tail
            ])),
            .listItem(SemanticListItem(kind: .numbered,
                runs: [SemanticRun(text: "café")]))
        ])
        let projection = try source.projection()
        let query = try #require(WritingFindQuery("café", caseSensitive: false))
        let results = WritingFindResults(query, in: projection)
        #expect(results.ranges == [NSRange(location: 0, length: 4),
                                   NSRange(location: 10, length: 4)])
        let proposal = try #require(WritingFindReplacement(
            results, ranges: results.ranges, text: "tea", in: projection
        ))
        let session = DocumentSession(state: source.state,
                                       initiallySaved: true)
        session.submit(proposal.command)
        let after = try #require(WritingProjection(session.state))
        #expect(after.text == "tea tail\ntea")
        #expect(session.history.undo.count == 1)
        let first = try #require(EditableSemanticBlock(
            session.document.content.blocks[0].block
        ))
        #expect(first.runs.last == tail)
        let secondBlock = session.document.content.blocks[1].block
        guard case let .listItem(item) = secondBlock
        else
        {
            Issue.record("Replace must preserve the list role")
            return
        }
        #expect(item.kind == .numbered)
        session.submit(DocumentHistoryCommand(observation: after.observation,
                                               direction: .undo))
        let restored = try #require(WritingProjection(session.state))
        #expect(Array(restored.text.utf16) == Array(projection.text.utf16))
        #expect(!session.isDirty)
        #expect(session.document.content == projection.snapshot.snapshot
            .document.content)
        #expect(WritingFindReplacement(results, ranges: results.ranges,
            text: "X", in: restored) == nil)
    }

    @Test("replacement refuses foreign ranges and multiline input atomically")
    func invalidReplacement() throws
    {
        let projection = try WritingTestDocument("cat cat").projection()
        let query = try #require(WritingFindQuery("cat", caseSensitive: false))
        let results = WritingFindResults(query, in: projection)
        #expect(WritingFindReplacement(results,
            ranges: [NSRange(location: 1, length: 2)], text: "x",
            in: projection) == nil)
        #expect(WritingFindReplacement(results, ranges: results.ranges,
            text: "x\ny", in: projection) == nil)
        let deletion = try #require(WritingFindReplacement(results,
            ranges: results.ranges, text: "", in: projection))
        let session = DocumentSession(state: .editable(projection.snapshot))
        session.submit(deletion.command)
        let after = try #require(WritingProjection(session.state))
        #expect(after.text == " ")
        #expect(session.history.undo.count == 1)
    }
}
