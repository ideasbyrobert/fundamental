import Testing

@testable import FundamentalDocument

extension ResolvedDocumentDeletionRangeTests
{
    @Test("foreign document identities are refused")
    func foreignDocumentIdentitiesAreRefused() throws
    {
        let range = try Self.range(
            start: 0,
            end: 1,
            documentMarker: 9
        )
        let document = try Self.document()

        #expect(ResolvedDocumentDeletionRange(
            range,
            in: document
        ) == nil)
    }

    @Test("stale revisions are refused")
    func staleRevisionsAreRefused() throws
    {
        let range = try Self.range(start: 0, end: 1, revision: 7)
        let document = try Self.document()

        #expect(ResolvedDocumentDeletionRange(
            range,
            in: document
        ) == nil)
    }

    @Test("out-of-bounds endpoints are refused")
    func outOfBoundsEndpointsAreRefused() throws
    {
        for bounds in [(0, 2), (2, 3)]
        {
            #expect(try Self.deletion(
                texts: ["A"],
                start: bounds.0,
                end: bounds.1
            ) == nil)
        }
    }

    @Test("surrogate interiors are refused")
    func surrogateInteriorsAreRefused() throws
    {
        for bounds in [(0, 1), (1, 2)]
        {
            #expect(try Self.deletion(
                texts: ["😀"],
                start: bounds.0,
                end: bounds.1
            ) == nil)
        }
    }

    @Test("runless blocks refuse noncollapsed deletion")
    func runlessBlocksRefuseDeletion() throws
    {
        #expect(try Self.deletion(
            texts: [],
            start: 0,
            end: 1
        ) == nil)
    }
}
