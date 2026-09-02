import Testing

@testable import FundamentalDocument

extension DocumentSnapshotTests
{
    static func snapshot(
        generation: UInt64 = 3,
        revision: UInt64 = 8,
        blocks: [(UInt8, SemanticBlock)]
    ) throws -> DocumentSnapshot
    {
        DocumentSnapshot(
            generation: SnapshotGeneration(generation),
            document: try ResolvedDocumentPointTests.document(
                revision: revision,
                blocks: blocks
            )
        )
    }

    static func selection(
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        startBlock: UInt8 = 2,
        startOffset: Int = 0,
        endBlock: UInt8 = 2,
        endOffset: Int = 0
    ) throws -> DocumentSelection
    {
        let start = try ResolvedDocumentPointTests.point(
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: startBlock,
            offset: startOffset
        )
        let end = try ResolvedDocumentPointTests.point(
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: endBlock,
            offset: endOffset
        )
        let range = try #require(DocumentRange(start: start, end: end))
        return DocumentSelection(range: range)
    }

    static func editableBlock(
        _ form: EditableDocumentBlockForm,
        text: String = "Text"
    ) -> SemanticBlock
    {
        switch form
        {
        case .paragraph:
            ResolvedDocumentRangeTests.paragraph(text)
        case .heading:
            ResolvedDocumentRangeTests.title(text)
        case .code:
            ResolvedDocumentRangeTests.code(text)
        }
    }
}
