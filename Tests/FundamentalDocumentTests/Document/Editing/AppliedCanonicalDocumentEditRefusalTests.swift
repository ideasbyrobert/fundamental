import Testing

@testable import FundamentalDocument

extension CanonicalDocumentEditTests
{
    @Test("the boundary matches representative specialized refusals")
    func boundaryMatchesRepresentativeRefusals() throws
    {
        let textSource = try Self.textSource()
        let staleInsertion = try AppliedSemanticTextEditTests.edit(
            at: 1,
            revision: 7
        )
        let textEdit = SemanticTextEdit.insertion(staleInsertion)
        let textOriginal = textSource

        #expect(AppliedSemanticTextEdit(
            textEdit,
            in: textSource
        ) == nil)
        #expect(AppliedCanonicalDocumentEdit(
            .text(textEdit),
            in: textSource
        ) == nil)
        #expect(textSource == textOriginal)

        let splitSource = try Self.mergeSource()
        let splitCandidate = try AppliedSemanticBlockSplitTests.request(
            at: 1,
            continuationMarker: 3
        )
        let split = try #require(splitCandidate)
        let splitOriginal = splitSource

        #expect(AppliedSemanticBlockSplit(split, in: splitSource) == nil)
        #expect(AppliedCanonicalDocumentEdit(
            .split(split),
            in: splitSource
        ) == nil)
        #expect(splitSource == splitOriginal)

        let mergeSource = try AppliedSemanticBlockMergeTests.document(blocks: [
            (2, AppliedSemanticTextEditTests.paragraph([
                SemanticRun(text: "AB")
            ])),
            (3, AppliedSemanticTextEditTests.plainCode([
                SemanticRun(text: "CD")
            ]))
        ])
        let mergeCandidate = try AppliedSemanticBlockMergeTests.request()
        let merge = try #require(mergeCandidate)
        let mergeOriginal = mergeSource

        #expect(AppliedSemanticBlockMerge(merge, in: mergeSource) == nil)
        #expect(AppliedCanonicalDocumentEdit(
            .merge(merge),
            in: mergeSource
        ) == nil)
        #expect(mergeSource == mergeOriginal)
    }
}
