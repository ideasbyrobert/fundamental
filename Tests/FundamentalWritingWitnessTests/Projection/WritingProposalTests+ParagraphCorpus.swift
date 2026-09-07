import Foundation
import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingProposalTests
{
    @MainActor
    @Test("every short paragraph span matches native replacement and undo")
    func paragraphReplacementCorpus() throws
    {
        let fixture = try WritingTestDocument(blocks: ["A", "BC", "", "D"].map
        {
            .paragraph(SemanticParagraph(runs: [SemanticRun(text: $0)]))
        })
        let projection = try fixture.projection()
        let native = projection.text as NSString
        for start in 0 ... native.length
        {
            for end in start ... native.length
            {
                for inserted in ["", "X", "\n", "\nY", "Q\n\nR"]
                {
                    let range = NSRange(location: start, length: end - start)
                    let proposal = WritingTextProposal(
                        ranges: [range], replacements: [inserted],
                        in: projection
                    )
                    if start == end && inserted.isEmpty
                    {
                        #expect(proposal == nil)
                        continue
                    }
                    let command = try #require(proposal).command
                    let session = DocumentSession(state: fixture.state)
                    session.submit(command)
                    let result = try #require(WritingProjection(session.state))
                    let expected = native.replacingCharacters(
                        in: range, with: inserted
                    )
                    #expect(result.text == expected)
                    #expect(session.document.revision.value == 9)
                    #expect(session.history.undo.count == 1)
                    #expect(result.selection.location == start +
                        inserted.utf16.count)
                    session.submit(DocumentHistoryCommand(
                        observation: session.observation, direction: .undo
                    ))
                    #expect(session.document.content ==
                        fixture.state.snapshot.document.content)
                }
            }
        }
    }
}
