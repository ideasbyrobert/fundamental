import Testing

@testable import FundamentalDocument

extension DocumentSessionStyleTests
{
    @Test("revision generation and history exhaustion preserve styling state")
    func exhaustion() throws
    {
        let cases: [(UInt64, UInt64, Int, DocumentSessionRefusal)] = [
            (.max, 3, 100, .invalidCommand),
            (8, .max, 100, .generationExhausted),
            (8, 3, 1, .historyCapacity)
        ]
        for (revision, generation, retained, refusal) in cases
        {
            let source = try SemanticWritingTestDocument(
                [.body], revision: revision
            )
            let session = DocumentSession(
                state: try source.state(generation: generation),
                historyLimits: try #require(DocumentHistoryLimits(
                    transactions: 4, retainedUTF16Units: retained
                )),
                initiallySaved: true
            )
            let before = session.current
            #expect(session.submit(.style(session.observation,
                SemanticBlockStyleChange(
                    range: try source.range((0, 0), (0, 0)), style: .bulleted
                )
            )) == .refused(refusal))
            #expect(session.current == before)
            #expect(!session.isDirty)
        }
    }

    @Test("formatting after a save starts remains dirty on acknowledgement")
    func pendingSave() throws
    {
        let source = try SemanticWritingTestDocument([.body])
        let session = DocumentSession(state: try source.state())
        let ticket = session.prepareSave()
        session.submit(.style(session.observation, SemanticBlockStyleChange(
            range: try source.range((0, 0), (0, 0)), style: .heading
        )))
        #expect(session.acknowledgeSave(ticket))
        #expect(session.isDirty)
        #expect(session.document.content != ticket.document.content)
    }
}
