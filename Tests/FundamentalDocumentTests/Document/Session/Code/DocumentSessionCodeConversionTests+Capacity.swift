import Testing

@testable import FundamentalDocument

extension DocumentSessionCodeConversionTests
{
    @Test("conversion exhaustion preserves history selection and dirty state")
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
                [.body, .body], revision: revision
            )
            let session = DocumentSession(
                state: try source.state(generation: generation),
                historyLimits: try #require(DocumentHistoryLimits(
                    transactions: 4, retainedUTF16Units: retained
                )),
                initiallySaved: true
            )
            let before = session.current
            let result = try session.submit(.convertCode(
                session.observation,
                SemanticCodeConversion(range: source.range((0, 0), (1, 4)))
            ))
            #expect(result == .refused(refusal))
            #expect(session.current == before)
            #expect(!session.isDirty)
        }
    }

    @Test("identical code conversion is a no-op even at exhausted counters")
    func unchanged() throws
    {
        for language in [nil, " SwIfT "] as [String?]
        {
            let source = try SemanticWritingTestDocument(blocks: [
                CodeConversionTestValue.code(
                    [SemanticRun(text: "\te\u{301}\r\n")], language: language
                )
            ], revision: .max)
            let session = DocumentSession(
                state: try source.state(generation: .max), initiallySaved: true
            )
            let before = session.current
            let conversion = SemanticCodeConversion(
                range: try source.range((0, 0), (0, 0)),
                codeLanguage: language.flatMap
                {
                    SemanticCodeLanguageIdentifier($0)
                }
            )
            #expect(session.submit(.convertCode(
                session.observation, conversion
            )) == .unchanged)
            #expect(session.current == before)
            #expect(!session.isDirty)
        }
    }
}
