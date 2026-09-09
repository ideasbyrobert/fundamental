import Testing

@testable import FundamentalDocument

extension AppliedSemanticCodeConversionTests
{
    @Test("continuation planning refuses foreign invalid and table documents")
    func proseContinuationCountsRefuseInvalidDocuments() throws
    {
        let source = try SemanticWritingTestDocument(
            [.monostyled], texts: ["😀\r\nA"]
        )
        #expect(try SemanticCodeConversion.proseContinuationCount(
            in: source.range((0, 1), (0, 1)), of: source.document
        ) == nil)
        let foreign = DocumentPoint(
            documentID: FundamentalDocumentID(
                DocumentRecordTestValue.identity(250)
            ), revision: source.document.revision,
            blockID: source.document.content.blocks[0].blockID,
            utf16Offset: try #require(DocumentUTF16Offset(0))
        )
        #expect(SemanticCodeConversion.proseContinuationCount(
            in: .caret(at: foreign), of: source.document
        ) == nil)
        let table = try #require(BlockRecordTestValue.blocks().first
        {
            if case .table = $0
            {
                return true
            }
            return false
        })
        let unsupported = try SemanticWritingTestDocument(blocks: [
            source.document.content.blocks[0].block, table
        ])
        #expect(try SemanticCodeConversion.proseContinuationCount(
            in: unsupported.range((0, 0), (0, 0)), of: unsupported.document
        ) == nil)
    }
}
