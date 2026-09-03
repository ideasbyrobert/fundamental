import Testing

@testable import FundamentalDocument

extension CanonicalDocumentEditTests
{
    @Test("block splitting matches its specialized result")
    func blockSplittingMatchesSpecializedResult() throws
    {
        let source = try Self.textSource()
        let candidate = try AppliedSemanticBlockSplitTests.request(at: 2)
        let split = try #require(candidate)
        let expected = try #require(AppliedSemanticBlockSplit(
            split,
            in: source
        ))
        let actual = try #require(AppliedCanonicalDocumentEdit(
            .split(split),
            in: source
        ))

        #expect(actual.document == expected.document)
        #expect(actual.caret == expected.caret)
    }

    @Test("block merging matches its specialized result")
    func blockMergingMatchesSpecializedResult() throws
    {
        let source = try Self.mergeSource()
        let candidate = try AppliedSemanticBlockMergeTests.request()
        let merge = try #require(candidate)
        let expected = try #require(AppliedSemanticBlockMerge(
            merge,
            in: source
        ))
        let actual = try #require(AppliedCanonicalDocumentEdit(
            .merge(merge),
            in: source
        ))

        #expect(actual.document == expected.document)
        #expect(actual.caret == expected.caret)
    }
}
