import Testing

@testable import FundamentalDocument

extension DocumentSessionCodeConversionTests
{
    @Test("stale and noncharacter conversions preserve the complete session")
    func staleAndInvalid() throws
    {
        let source = try SemanticWritingTestDocument(
            [.monostyled], texts: ["😀e\u{301}\r\nB"]
        )
        let session = DocumentSession(
            state: try source.state(), initiallySaved: true
        )
        let stale = session.observation
        session.submit(.select(session.observation, DocumentSelection(
            range: try source.range((0, 2), (0, 2))
        )))
        let before = session.current
        let language = try #require(SemanticCodeLanguageIdentifier("Swift"))
        let valid = SemanticCodeConversion(
            range: try source.range((0, 0), (0, 0)), codeLanguage: language
        )
        #expect(session.submit(.convertCode(stale, valid)) ==
            .refused(.staleObservation))
        for offset in [1, 3, 5, 8]
        {
            let conversion = SemanticCodeConversion(
                range: try source.range((0, offset), (0, offset)),
                codeLanguage: language
            )
            #expect(session.submit(.convertCode(
                session.observation, conversion
            )) == .refused(.invalidCommand))
            #expect(session.current == before)
            #expect(!session.isDirty)
        }
    }

    @Test("missing extra and colliding continuation identities refuse")
    func invalidIdentities() throws
    {
        let source = try SemanticWritingTestDocument(
            [.body, .monostyled], texts: ["Before", "A\r\nB"]
        )
        let session = DocumentSession(
            state: try source.state(), initiallySaved: true
        )
        let before = session.current
        let original = source.document.content.blocks.map(\.blockID)
        let cases = [[], CodeConversionTestValue.identities(2),
                     [original[0]], [original[1]]]
        let range = try source.range((1, 0), (1, 0))
        for identities in cases
        {
            let conversion = try #require(SemanticCodeConversion(
                range: range, proseStyle: .body,
                continuationBlockIDs: identities
            ))
            #expect(session.submit(.convertCode(
                session.observation, conversion
            )) == .refused(.invalidCommand))
            #expect(session.current == before)
            #expect(!session.isDirty)
        }
        let fresh = CodeConversionTestValue.identities(1)[0]
        #expect(SemanticCodeConversion(
            range: range, proseStyle: .body,
            continuationBlockIDs: [fresh, fresh]
        ) == nil)
        #expect(SemanticCodeConversion(
            range: range, proseStyle: .monostyled
        ) == nil)
    }
}
