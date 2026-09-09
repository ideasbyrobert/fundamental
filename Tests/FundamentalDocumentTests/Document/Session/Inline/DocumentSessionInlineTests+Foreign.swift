import Testing

@testable import FundamentalDocument

extension DocumentSessionInlineTests
{
    @Test("foreign document revision and block coordinates refuse atomically")
    func foreignCoordinates() throws
    {
        let source = try SemanticWritingTestDocument([.body])
        let session = DocumentSession(
            state: try source.state(), initiallySaved: true
        )
        let before = session.current
        let document = source.document
        let blockID = document.content.blocks[0].blockID
        let zero = try #require(DocumentUTF16Offset(0))
        let points = [
            DocumentPoint(
                documentID: FundamentalDocumentID(
                    DocumentRecordTestValue.identity(250)
                ), revision: document.revision,
                blockID: blockID, utf16Offset: zero
            ),
            DocumentPoint(
                documentID: document.documentID, revision: DocumentRevision(9),
                blockID: blockID, utf16Offset: zero
            ),
            DocumentPoint(
                documentID: document.documentID, revision: document.revision,
                blockID: FundamentalBlockID(
                    DocumentRecordTestValue.identity(251)
                ), utf16Offset: zero
            )
        ]
        for point in points
        {
            #expect(session.submit(.inline(session.observation,
                SemanticInlineTraitChange(range: .caret(at: point),
                                          trait: .strong, enabled: true)
            )) == .refused(.invalidCommand))
            #expect(session.current == before)
            #expect(!session.isDirty)
        }
    }
}
