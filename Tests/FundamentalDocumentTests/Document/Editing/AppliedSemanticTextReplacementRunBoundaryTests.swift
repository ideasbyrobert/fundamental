import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextReplacementTests
{
    @Test("empty runs follow the half-open partition law")
    func emptyRunsFollowPartitionLaw() throws
    {
        let sourceRuns = [
            SemanticRun(text: ""), SemanticRun(text: "A"),
            SemanticRun(text: ""), SemanticRun(text: "B"),
            SemanticRun(text: ""), SemanticRun(text: "C"),
            SemanticRun(text: "")
        ]
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph(sourceRuns))
        ]
        let candidate = try Self.apply(
            start: 1,
            end: 2,
            blocks: blocks
        )
        let result = try #require(candidate)

        #expect(try Self.runs(in: result).map(\.text) == [
            "", "A", "X", "", "C", ""
        ])
    }
}
