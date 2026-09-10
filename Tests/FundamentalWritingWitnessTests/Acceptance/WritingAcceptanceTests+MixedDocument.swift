import Testing

@testable import FundamentalDocument
@testable import FundamentalWritingWitness

extension WritingAcceptanceTests
{
    @Test("mixed semantics survive native editing files and Reader rebuilding",
          arguments: ["fun", "fundamental"])
    func mixedDocumentJourney(suffix: String) async throws
    {
        let session = try WritingMixedDocumentFixture.editedSession()
        let retained = DocumentSessionStorage(
            state: session.state, history: session.history
        )
        let source = try await WritingMixedDocumentFixture.reopen(
            session, suffix: suffix
        )
        #expect(source.document == session.document)
        #expect(session.state == retained.state)
        #expect(session.history == retained.history)
        try WritingMixedDocumentFixture.read(source, suffix: suffix)
    }
}
