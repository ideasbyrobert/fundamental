import Testing

@testable import FundamentalDocument

extension DocumentSessionStyleTests
{
    @Test("list removal refuses stale observations and split graphemes")
    func removeListsInvalidRange() throws
    {
        let source = try SemanticWritingTestDocument(
            [.bulleted], texts: ["😀e\u{301}"]
        )
        let session = DocumentSession(state: try source.state())
        let stale = session.observation
        session.submit(.select(session.observation, DocumentSelection(
            range: try source.range((0, 2), (0, 2))
        )))
        let before = session.current
        #expect(session.submit(.style(stale, SemanticBlockStyleChange(
            removingListsIn: try source.range((0, 0), (0, 0))
        ))) == .refused(.staleObservation))
        for offset in [1, 3]
        {
            #expect(session.submit(.style(session.observation,
                SemanticBlockStyleChange(
                    removingListsIn: try source.range((0, offset), (0, 4))
                )
            )) == .refused(.invalidCommand))
        }
        #expect(session.current == before)
    }
}
