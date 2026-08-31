import Foundation
import Testing

@testable import FundamentalDocument

@Suite("A fundamental block identity")
struct FundamentalBlockIDTests
{
    @Test("initialization preserves the exact UUID")
    func initializationPreservesExactUUID() throws
    {
        let value = try #require(
            UUID(uuidString: "11111111-aaaa-bbbb-cccc-222222222222")
        )
        let identity = FundamentalBlockID(value)

        #expect(identity.value == value)
    }

    @Test("equal values share identity and distinct values do not")
    func equalityAndHashingFollowExactValues() throws
    {
        let firstValue = try #require(
            UUID(uuidString: "aaaaaaaa-1111-2222-3333-bbbbbbbbbbbb")
        )
        let secondValue = try #require(
            UUID(uuidString: "cccccccc-4444-5555-6666-dddddddddddd")
        )
        let first = FundamentalBlockID(firstValue)
        let equal = FundamentalBlockID(firstValue)
        let distinct = FundamentalBlockID(secondValue)

        #expect(first == equal)
        #expect(first != distinct)
        #expect(Set([first, equal, distinct]).count == 2)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let originalValue = try #require(
            UUID(uuidString: "12345678-abcd-abcd-abcd-123456789abc")
        )
        let replacementValue = try #require(
            UUID(uuidString: "87654321-dcba-dcba-dcba-cba987654321")
        )
        let original = FundamentalBlockID(originalValue)
        let replacement = FundamentalBlockID(replacementValue)

        #expect(original.value == originalValue)
        #expect(replacement.value == replacementValue)
        #expect(original != replacement)
    }
}
