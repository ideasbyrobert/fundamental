import Testing

@testable import FundamentalDocument

extension DocumentSessionStyleTests
{
    @Test("reapplying a style preserves state history and dirty state")
    func unchanged() throws
    {
        let source = try SemanticWritingTestDocument([.numbered])
        let session = DocumentSession(
            state: try source.state(), initiallySaved: true
        )
        let before = session.current
        #expect(session.submit(.style(session.observation,
            SemanticBlockStyleChange(
                range: try source.range((0, 0), (0, 0)), style: .numbered
            )
        )) == .unchanged)
        #expect(session.current == before)
        #expect(!session.isDirty)
    }

    @Test("stale observations and noncharacter ranges cannot style text")
    func staleAndInvalid() throws
    {
        let source = try SemanticWritingTestDocument([.body], texts: ["😀é"])
        let session = DocumentSession(state: try source.state())
        let stale = session.observation
        session.submit(.select(session.observation, DocumentSelection(
            range: try source.range((0, 2), (0, 2))
        )))
        let before = session.current
        #expect(session.submit(.style(stale, SemanticBlockStyleChange(
            range: try source.range((0, 0), (0, 0)), style: .title
        ))) == .refused(.staleObservation))
        #expect(session.submit(.style(session.observation,
            SemanticBlockStyleChange(
                range: try source.range((0, 1), (0, 2)), style: .title
            )
        )) == .refused(.invalidCommand))
        #expect(session.current == before)
    }

    @Test("code and unsupported target styles refuse atomically")
    func unsupported() throws
    {
        let cases: [(CanonicalBlockStyle, CanonicalBlockStyle)] = [
            (.monostyled, .body), (.body, .monostyled)
        ]
        for (original, target) in cases
        {
            let source = try SemanticWritingTestDocument([.body, original])
            let session = DocumentSession(state: try source.state())
            let before = session.current
            #expect(session.submit(.style(session.observation,
                SemanticBlockStyleChange(
                    range: try source.range((0, 0), (1, 4)), style: target
                )
            )) == .refused(.invalidCommand))
            #expect(session.current == before)
        }
    }
}
