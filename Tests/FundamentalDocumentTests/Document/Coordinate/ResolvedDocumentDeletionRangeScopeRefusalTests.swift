import Testing

@testable import FundamentalDocument

extension ResolvedDocumentDeletionRangeTests
{
    @Test("collapsed ranges are refused before boundary publication")
    func collapsedRangesAreRefused() throws
    {
        for offset in 0...2
        {
            #expect(try Self.deletion(
                texts: ["e\u{301}"],
                start: offset,
                end: offset
            ) == nil)
        }
    }

    @Test("cross-block ranges are refused")
    func crossBlockRangesAreRefused() throws
    {
        let document = try ResolvedDocumentRangeTests.document(blocks: [
            (2, ResolvedDocumentRangeTests.paragraph("A")),
            (3, ResolvedDocumentRangeTests.paragraph("B"))
        ])
        let range = try Self.range(
            start: 0,
            end: 1,
            startBlock: 2,
            endBlock: 3
        )

        #expect(ResolvedDocumentDeletionRange(range, in: document) == nil)
    }

    @Test("table blocks are refused")
    func tableBlocksAreRefused() throws
    {
        let document = try ResolvedDocumentRangeTests.document(blocks: [
            (2, .table(SemanticBlockTests.emptyTableRecord()))
        ])
        let range = try Self.range(start: 0, end: 1)

        #expect(ResolvedDocumentDeletionRange(range, in: document) == nil)
    }

    @Test("missing block identities are refused")
    func missingBlockIdentitiesAreRefused() throws
    {
        let range = try Self.range(
            start: 0,
            end: 1,
            startBlock: 9,
            endBlock: 9
        )
        let document = try Self.document()

        #expect(ResolvedDocumentDeletionRange(
            range,
            in: document
        ) == nil)
    }
}
