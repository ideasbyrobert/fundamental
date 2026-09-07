import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

@MainActor
@Suite("Manuscript writing capacity")
struct WritingManuscriptCapacityTests
{
    @Test("the largest admitted text retains sixty-four full undo transactions")
    func largestHistory() throws
    {
        let capacity = WritingSurfacePolicy.maximumUTF16Units
        let source = try WritingTestDocument(String(repeating: "A",
                                                    count: capacity))
        let session = DocumentSession(state: source.state, initiallySaved: true)
        for index in 0 ..< 65
        {
            let projection = try #require(WritingProjection(session.state))
            let edit = try #require(WritingTextProposal(
                ranges: [NSRange(location: 0, length: 1)],
                replacements: [index.isMultiple(of: 2) ? "B" : "C"],
                in: projection
            ))
            guard case .applied = session.submit(edit.command)
            else
            {
                Issue.record("an admitted manuscript edit was refused")
                return
            }
            #expect(session.history.undo.count == min(index + 1, 64))
        }
        #expect(session.history.retainedUTF16Units == capacity * 2 * 64)
        for _ in 0 ..< 64
        {
            guard case .applied = session.submit(DocumentHistoryCommand(
                observation: session.observation, direction: .undo
            ))
            else
            {
                Issue.record("retained manuscript undo was refused")
                return
            }
        }
        #expect(!session.canUndo)
        #expect(session.history.redo.count == 64)
        let result = try #require(WritingProjection(session.state))
        #expect(result.text.utf16.count == capacity)
        #expect(result.text.first == "B")
        #expect(session.isDirty)
    }
}
