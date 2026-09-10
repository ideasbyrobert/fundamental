import Testing

@testable import FundamentalDocument

extension DocumentSessionScopeTests
{
    @Test("foreign document revision and block scope coordinates refuse")
    func foreignCoordinates() throws
    {
        let source = try SemanticWritingTestDocument([.body])
        let document = source.document
        let session = DocumentSession(state: try source.state(),
                                      initiallySaved: true)
        let zero = try #require(DocumentUTF16Offset(0))
        let blockID = document.content.blocks[0].blockID
        let points = [
            DocumentPoint(documentID: FundamentalDocumentID(
                DocumentRecordTestValue.identity(250)
            ), revision: document.revision, blockID: blockID,
                utf16Offset: zero),
            DocumentPoint(documentID: document.documentID,
                revision: DocumentRevision(9), blockID: blockID,
                utf16Offset: zero),
            DocumentPoint(documentID: document.documentID,
                revision: document.revision, blockID: FundamentalBlockID(
                    DocumentRecordTestValue.identity(251)
                ), utf16Offset: zero)
        ]
        let before = session.current
        for point in points
        {
            #expect(session.submit(.scope(session.observation,
                SemanticRunScopeChange(range: .caret(at: point),
                    assignment: try ScopeTestValue.assignments()[2])
            )) == .refused(.invalidCommand))
            #expect(session.current == before && !session.isDirty)
        }
    }
}
