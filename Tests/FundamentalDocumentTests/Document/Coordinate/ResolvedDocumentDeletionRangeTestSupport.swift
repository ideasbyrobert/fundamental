import Testing

@testable import FundamentalDocument

extension ResolvedDocumentDeletionRangeTests
{
    static func document(
        texts: [String] = ["Text"],
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 2
    ) throws -> CanonicalDocument
    {
        try ResolvedDocumentPointTests.document(
            documentMarker: documentMarker,
            revision: revision,
            blocks: [(blockMarker, .paragraph(SemanticParagraph(
                runs: texts.map
                {
                    SemanticRun(text: $0)
                }
            )))]
        )
    }

    static func range(
        start: Int,
        end: Int,
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        startBlock: UInt8 = 2,
        endBlock: UInt8 = 2
    ) throws -> DocumentRange
    {
        let startPoint = try ResolvedDocumentPointTests.point(
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: startBlock,
            offset: start
        )
        let endPoint = try ResolvedDocumentPointTests.point(
            documentMarker: documentMarker,
            revision: revision,
            blockMarker: endBlock,
            offset: end
        )
        return try #require(DocumentRange(
            start: startPoint,
            end: endPoint
        ))
    }

    static func deletion(
        texts: [String] = ["Text"],
        start: Int,
        end: Int
    ) throws -> ResolvedDocumentDeletionRange?
    {
        ResolvedDocumentDeletionRange(
            try range(start: start, end: end),
            in: try document(texts: texts)
        )
    }
}
