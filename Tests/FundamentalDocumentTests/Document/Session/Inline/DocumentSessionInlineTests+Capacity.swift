import Testing

@testable import FundamentalDocument

extension DocumentSessionInlineTests
{
    @Test("exhaustion preserves content selection history and dirty state")
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
            #expect(session.submit(.inline(session.observation,
                SemanticInlineTraitChange(
                    range: try source.range((0, 1), (0, 3)),
                    trait: .strong, enabled: true
                )
            )) == .refused(refusal))
            #expect(session.current == before)
            #expect(!session.isDirty)
        }
    }

    @Test("matching formatting is unchanged at exhausted counters")
    func unchanged() throws
    {
        let source = try SemanticWritingTestDocument(blocks: [
            .paragraph(SemanticParagraph(runs: [
                SemanticRun(text: "ABCD", traits: [.strong])
            ]))
        ], revision: .max)
        let session = DocumentSession(
            state: try source.state(generation: .max), initiallySaved: true
        )
        let before = session.current
        for range in [try source.range((0, 1), (0, 3)),
                      try source.range((0, 2), (0, 2))]
        {
            #expect(session.submit(.inline(session.observation,
                SemanticInlineTraitChange(range: range, trait: .strong,
                                          enabled: true)
            )) == .unchanged)
            #expect(session.current == before)
            #expect(!session.isDirty)
        }
    }
}
