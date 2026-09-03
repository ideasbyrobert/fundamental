import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockMergeTests
{
    @Test("foreign stale and missing requests refuse atomically")
    func foreignStaleAndMissingRequestsRefuseAtomically() throws
    {
        let block = Self.paragraph([SemanticRun(text: "A")])
        let source = try Self.document(blocks: [(2, block), (3, block)])
        let original = source
        let requests = try [
            Self.request(documentMarker: 9),
            Self.request(revision: 9),
            Self.request(leadingMarker: 9),
            Self.request(trailingMarker: 9)
        ]
        for candidate in requests
        {
            let request = try #require(candidate)
            #expect(AppliedSemanticBlockMerge(request, in: source) == nil)
            #expect(source == original)
        }
    }

    @Test("a table anywhere refuses the complete merge")
    func tableAnywhereRefusesCompleteMerge() throws
    {
        let table = try DocumentSnapshotTests.tableBlock()
        let text = Self.paragraph([SemanticRun(text: "A")])
        let cases: [([(UInt8, SemanticBlock)], UInt8, UInt8)] = [
            ([(2, table), (3, text)], 2, 3),
            ([(2, text), (3, table)], 2, 3),
            ([(7, table), (2, text), (3, text)], 2, 3),
            ([(2, text), (3, text), (7, table)], 2, 3)
        ]

        for item in cases
        {
            let source = try Self.document(blocks: item.0)
            let original = source
            #expect(try Self.apply(
                leadingMarker: item.1,
                trailingMarker: item.2,
                in: source
            ) == nil)
            #expect(source == original)
        }
    }
}
