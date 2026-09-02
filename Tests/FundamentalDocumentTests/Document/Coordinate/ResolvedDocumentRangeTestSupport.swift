import Testing

@testable import FundamentalDocument

extension ResolvedDocumentRangeTests
{
    static func document(
        blocks: [(marker: UInt8, block: SemanticBlock)]
    ) throws -> CanonicalDocument
    {
        try ResolvedDocumentPointTests.document(blocks: blocks)
    }

    static func point(
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2,
        offset: Int = 0
    ) throws -> DocumentPoint
    {
        try ResolvedDocumentPointTests.point(
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: blockMarker,
            offset: offset
        )
    }

    static func range(
        _ start: DocumentPoint,
        _ end: DocumentPoint
    ) throws -> DocumentRange
    {
        try #require(DocumentRange(start: start, end: end))
    }

    static func paragraph(_ text: String) -> SemanticBlock
    {
        ResolvedDocumentPointTests.paragraph([text])
    }

    static func title(_ text: String) -> SemanticBlock
    {
        .heading(.title(TitleSemanticHeading(
            runs: [SemanticRun(text: text)]
        )))
    }

    static func code(_ text: String) -> SemanticBlock
    {
        .code(.plain(PlainSemanticCodeBlock(
            runs: [SemanticRun(text: text)]
        )))
    }
}
