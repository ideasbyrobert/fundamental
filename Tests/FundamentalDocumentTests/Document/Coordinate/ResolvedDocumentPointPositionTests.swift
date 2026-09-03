import Testing

@testable import FundamentalDocument

extension ResolvedDocumentPointTests
{
    @Test("block positions decompose with left-biased run edges")
    func blockPositionsDecomposeDeterministically() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph(["AB", "CD"]))
        ])
        let expected = [
            (0, 0, 0),
            (1, 0, 1),
            (2, 0, 2),
            (3, 1, 1),
            (4, 1, 2)
        ]

        for (blockOffset, runIndex, runOffset) in expected
        {
            let point = try Self.point(offset: blockOffset)
            let resolved = try #require(
                ResolvedDocumentPoint(point, in: document)
            )
            #expect(resolved.runPosition == .run(
                index: runIndex,
                utf16Offset: try Self.offset(runOffset)
            ))
        }
    }

    @Test("a runless block resolves only zero as no-runs")
    func runlessBlockResolvesZero() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph([]))
        ])
        let resolved = try #require(
            ResolvedDocumentPoint(try Self.point(), in: document)
        )

        #expect(resolved.runPosition == .noRuns)
    }

    @Test("a different document identity is refused")
    func differentDocumentIsRefused() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph(["A"]))
        ])
        let point = try Self.point(documentMarker: 9)

        #expect(ResolvedDocumentPoint(point, in: document) == nil)
    }

    @Test("a stale content revision is refused")
    func staleRevisionIsRefused() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph(["A"]))
        ])
        let point = try Self.point(revision: 7)

        #expect(ResolvedDocumentPoint(point, in: document) == nil)
    }

    @Test("missing and table block identities are refused")
    func missingAndTableBlocksAreRefused() throws
    {
        let table = SemanticBlock.table(
            try SemanticBlockTests.emptyTableRecord()
        )
        let document = try Self.document(blocks: [(2, table)])

        #expect(ResolvedDocumentPoint(
            try Self.point(blockMarker: 3),
            in: document
        ) == nil)
        #expect(ResolvedDocumentPoint(
            try Self.point(blockMarker: 2),
            in: document
        ) == nil)
    }

    @Test("invalid text boundaries are refused")
    func invalidTextBoundariesAreRefused() throws
    {
        let document = try Self.document(blocks: [
            (2, Self.paragraph(["A🌍e\u{301}"]))
        ])
        for offset in [2, 4, 6]
        {
            let point = try Self.point(offset: offset)
            #expect(ResolvedDocumentPoint(point, in: document) == nil)
        }
    }
}
