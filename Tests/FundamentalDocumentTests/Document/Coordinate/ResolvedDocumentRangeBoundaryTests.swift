import Testing

@testable import FundamentalDocument

extension ResolvedDocumentRangeTests
{
    @Test("a caret has one directional and ordered boundary")
    func caretHasOneBoundary() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph("AB"))
        ])
        let point = try Self.point(offset: 1)
        let resolved = try #require(ResolvedDocumentRange(
            .caret(at: point),
            in: document
        ))

        #expect(resolved.start == resolved.end)
        #expect(resolved.lowerBound == resolved.start)
        #expect(resolved.upperBound == resolved.start)
    }

    @Test("any invalid endpoint refuses the complete range")
    func anyInvalidEndpointRefusesCompleteRange() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph("A🌍"))
        ])
        let point = try Self.point(offset: 0)
        let invalidRanges = [
            try Self.range(Self.point(blockMarker: 9), point),
            try Self.range(point, Self.point(offset: 2)),
            try Self.range(
                Self.point(documentMarker: 9),
                Self.point(documentMarker: 9)
            ),
            try Self.range(
                Self.point(revision: 7),
                Self.point(revision: 7)
            )
        ]

        for range in invalidRanges
        {
            #expect(ResolvedDocumentRange(range, in: document) == nil)
        }
    }

    @Test("paragraph heading and code form one editable span")
    func editableFormsCreateOneSpan() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph("P")),
            (3, Self.title("H")),
            (4, Self.code("C"))
        ])
        let range = try Self.range(
            Self.point(blockMarker: 2),
            Self.point(blockMarker: 4, offset: 1)
        )
        let resolved = try #require(
            ResolvedDocumentRange(range, in: document)
        )

        #expect(resolved.lowerBound.blockIndex == 0)
        #expect(resolved.upperBound.blockIndex == 2)
    }

    @Test("a table endpoint or crossed table refuses the whole range")
    func anyTableInSpanRefusesWholeRange() throws
    {
        let table = SemanticBlock.table(
            SemanticBlockTests.emptyTableRecord()
        )
        let document = try Self.document(blocks: [
            (2, Self.paragraph("P")),
            (3, table),
            (4, Self.code("C"))
        ])
        let points = try [2, 3, 4].map
        {
            try Self.point(blockMarker: UInt8($0))
        }
        let refused = [
            try Self.range(points[0], points[1]),
            try Self.range(points[1], points[2]),
            try Self.range(points[0], points[2]),
            try Self.range(points[2], points[0])
        ]

        for range in refused
        {
            #expect(ResolvedDocumentRange(range, in: document) == nil)
        }
    }
}
