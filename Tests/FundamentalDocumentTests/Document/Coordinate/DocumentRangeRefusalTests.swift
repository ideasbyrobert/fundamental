import Testing

@testable import FundamentalDocument

extension DocumentRangeTests
{
    @Test("different document identities are refused")
    func differentDocumentIdentitiesAreRefused() throws
    {
        let start = try Self.point(documentMarker: 1)
        let end = try Self.point(documentMarker: 2)

        #expect(DocumentRange(start: start, end: end) == nil)
    }

    @Test("different document revisions are refused")
    func differentDocumentRevisionsAreRefused() throws
    {
        let start = try Self.point(revision: 8)
        let end = try Self.point(revision: 9)

        #expect(DocumentRange(start: start, end: end) == nil)
    }
}
