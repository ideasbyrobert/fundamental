import Testing

@testable import FundamentalDocument

extension DocumentSessionScopeTests
{
    @Test("scope capacity refusal is atomic")
    func capacity() throws
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
                )), initiallySaved: true
            )
            let before = session.current
            #expect(session.submit(.scope(session.observation,
                SemanticRunScopeChange(range: try source.range((0, 1), (0, 3)),
                    assignment: try ScopeTestValue.assignments()[0])
            )) == .refused(refusal))
            #expect(session.current == before && !session.isDirty)
        }
    }

    @Test("scope no-ops remain unchanged at exhausted counters")
    func unchanged() throws
    {
        let attributes = try ScopeTestValue.attributes(
            link: ScopeTestValue.newLink
        )
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [SemanticRun(
                text: "ABCD", attributes: attributes
            )]))
        ], revision: .max)
        let session = DocumentSession(state: try source.state(generation: .max),
                                      initiallySaved: true)
        let before = session.current
        for range in [try source.range((0, 1), (0, 3)),
                      try source.range((0, 2), (0, 2))]
        {
            #expect(session.submit(.scope(session.observation,
                SemanticRunScopeChange(range: range,
                    assignment: try ScopeTestValue.assignments()[0])
            )) == .unchanged)
            #expect(session.current == before && !session.isDirty)
        }
    }
}
