import Foundation
import Testing

@testable import FundamentalDocument

@Suite("A document range")
struct DocumentRangeTests
{
    @Test("construction preserves compatible endpoints and scope")
    func constructionPreservesEndpointsAndScope() throws
    {
        let start = try Self.point(blockMarker: 2, offset: 3)
        let end = try Self.point(blockMarker: 7, offset: 11)
        let range = try #require(DocumentRange(start: start, end: end))

        #expect(range.start == start)
        #expect(range.end == end)
        #expect(range.documentID == start.documentID)
        #expect(range.revision == start.revision)
    }

    @Test("same-block and cross-block direction is preserved")
    func endpointDirectionIsPreserved() throws
    {
        let pairs = [
            (
                try Self.point(blockMarker: 2, offset: 13),
                try Self.point(blockMarker: 2, offset: 3)
            ),
            (
                try Self.point(blockMarker: 8, offset: 1),
                try Self.point(blockMarker: 3, offset: 21)
            )
        ]

        for (start, end) in pairs
        {
            let range = try #require(
                DocumentRange(start: start, end: end)
            )
            #expect(range.start == start)
            #expect(range.end == end)
        }
    }

    @Test("caret and extended ranges derive exact collapsed state")
    func collapsedStateIsDerived() throws
    {
        let point = try Self.point(offset: 5)
        let caret = DocumentRange.caret(at: point)
        let extended = try #require(
            DocumentRange(
                start: point,
                end: Self.point(offset: 8)
            )
        )

        #expect(caret.start == point)
        #expect(caret.end == point)
        #expect(caret.isCollapsed)
        #expect(!extended.isCollapsed)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let start = try Self.point(offset: 2)
        let original = try #require(
            DocumentRange(start: start, end: Self.point(offset: 5))
        )
        let replacement = try #require(
            DocumentRange(start: start, end: Self.point(offset: 9))
        )

        #expect(original.end.utf16Offset.value == 5)
        #expect(replacement.end.utf16Offset.value == 9)
    }

    static func point(
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 3,
        offset: Int = 0
    ) throws -> DocumentPoint
    {
        DocumentPoint(
            documentID: FundamentalDocumentID(uuid(documentMarker)),
            revision: DocumentRevision(revision),
            blockID: FundamentalBlockID(uuid(blockMarker)),
            utf16Offset: try #require(DocumentUTF16Offset(offset))
        )
    }

    private static func uuid(_ marker: UInt8) -> UUID
    {
        UUID(uuid: (marker, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    }
}
