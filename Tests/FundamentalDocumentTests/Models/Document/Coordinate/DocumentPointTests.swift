import Foundation
import Testing

@testable import FundamentalDocument

@Suite("A document point")
struct DocumentPointTests
{
    @Test("construction preserves every required address fact")
    func constructionPreservesAddressFacts() throws
    {
        let point = try point()

        #expect(point.documentID == FundamentalDocumentID(uuid(1)))
        #expect(point.revision == DocumentRevision(8))
        #expect(point.blockID == FundamentalBlockID(uuid(3)))
        #expect(point.utf16Offset.value == 13)
    }

    @Test("every address component participates in equality")
    func everyAddressComponentParticipatesInEquality() throws
    {
        let base = try point()
        let equal = try point()
        let variants = [
            try point(documentMarker: 2),
            try point(revision: 9),
            try point(blockMarker: 4),
            try point(utf16Offset: 14)
        ]

        #expect(base == equal)
        #expect(variants.allSatisfy { $0 != base })
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let original = try point()
        let replacement = try point(
            revision: 9,
            utf16Offset: 21
        )

        #expect(original.revision == DocumentRevision(8))
        #expect(original.utf16Offset.value == 13)
        #expect(replacement.revision == DocumentRevision(9))
        #expect(replacement.utf16Offset.value == 21)
    }

    private func point(
        documentMarker: UInt8 = 1,
        revision: UInt64 = 8,
        blockMarker: UInt8 = 3,
        utf16Offset: Int = 13
    ) throws -> DocumentPoint
    {
        DocumentPoint(
            documentID: FundamentalDocumentID(uuid(documentMarker)),
            revision: DocumentRevision(revision),
            blockID: FundamentalBlockID(uuid(blockMarker)),
            utf16Offset: try #require(DocumentUTF16Offset(utf16Offset))
        )
    }

    private func uuid(_ marker: UInt8) -> UUID
    {
        UUID(uuid: (marker, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    }
}
