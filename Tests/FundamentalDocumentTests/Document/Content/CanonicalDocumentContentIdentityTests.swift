import Testing

@testable import FundamentalDocument

extension CanonicalDocumentContentTests
{
    @Test("repeated identities at any position are refused")
    func repeatedIdentitiesAreRefused()
    {
        let first = Self.identified(marker: 1, text: "First")
        let second = Self.identified(marker: 2, text: "Second")
        let repeatedFirst = Self.identified(marker: 1, text: "Other")
        let repeatedSecond = Self.identified(marker: 2, text: "Other")

        #expect(
            CanonicalDocumentContent(
                firstBlock: first,
                remainingBlocks: [repeatedFirst]
            ) == nil
        )
        #expect(
            CanonicalDocumentContent(
                firstBlock: first,
                remainingBlocks: [second, repeatedSecond]
            ) == nil
        )
    }

    @Test("equal payloads under distinct identities remain admitted")
    func equalPayloadsRemainAdmitted() throws
    {
        let first = Self.identified(marker: 1, text: "Shared")
        let second = Self.identified(marker: 2, text: "Shared")
        let content = try #require(
            CanonicalDocumentContent(
                firstBlock: first,
                remainingBlocks: [second]
            )
        )

        #expect(content.blocks.map(\.block) == [first.block, second.block])
        #expect(first.blockID != second.blockID)
    }

    @Test("reconstruction leaves the original unchanged")
    func reconstructionLeavesOriginalUnchanged() throws
    {
        let first = Self.identified(marker: 1, text: "First")
        let second = Self.identified(marker: 2, text: "Second")
        let third = Self.identified(marker: 3, text: "Third")
        let original = try #require(
            CanonicalDocumentContent(
                firstBlock: first,
                remainingBlocks: [second]
            )
        )
        let replacement = try #require(
            CanonicalDocumentContent(
                firstBlock: first,
                remainingBlocks: [third]
            )
        )

        #expect(original.blocks == [first, second])
        #expect(replacement.blocks == [first, third])
    }
}
