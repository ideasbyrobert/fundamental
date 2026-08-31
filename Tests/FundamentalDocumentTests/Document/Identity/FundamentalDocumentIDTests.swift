import Foundation
import Testing

@testable import FundamentalDocument

@Suite("A fundamental document identity")
struct FundamentalDocumentIDTests
{
    @Test("initialization preserves the exact UUID")
    func initializationPreservesExactUUID() throws
    {
        let value = try #require(
            UUID(uuidString: "11111111-2222-3333-4444-555555555555")
        )
        let identity = FundamentalDocumentID(value)

        #expect(identity.value == value)
    }

    @Test("equal values share identity and distinct values do not")
    func equalityAndHashingFollowExactValues() throws
    {
        let firstValue = try #require(
            UUID(uuidString: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
        )
        let secondValue = try #require(
            UUID(uuidString: "00000000-1111-2222-3333-444444444444")
        )
        let first = FundamentalDocumentID(firstValue)
        let equal = FundamentalDocumentID(firstValue)
        let distinct = FundamentalDocumentID(secondValue)

        #expect(first == equal)
        #expect(first != distinct)
        #expect(Set([first, equal, distinct]).count == 2)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let originalValue = try #require(
            UUID(uuidString: "12345678-1234-1234-1234-123456789abc")
        )
        let replacementValue = try #require(
            UUID(uuidString: "abcdefab-cdef-cdef-cdef-abcdefabcdef")
        )
        let original = FundamentalDocumentID(originalValue)
        let replacement = FundamentalDocumentID(replacementValue)

        #expect(original.value == originalValue)
        #expect(replacement.value == replacementValue)
        #expect(original != replacement)
    }
}
