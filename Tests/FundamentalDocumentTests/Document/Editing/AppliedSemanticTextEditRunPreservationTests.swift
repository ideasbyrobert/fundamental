import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextEditTests
{
    @Test("equal adjacent attributes remain separate runs")
    func equalAdjacentAttributesRemainSeparateRuns() throws
    {
        let attributes = SemanticRunAttributes.direct(traits: [.strong])
        let sourceRun = SemanticRun(text: "AB", attributes: attributes)
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([sourceRun]))
        ]
        let candidate = try Self.apply(
            text: "X",
            attributes: attributes,
            at: 1,
            blocks: blocks
        )
        let result = try #require(candidate)
        let runs = try Self.runs(in: result)

        #expect(runs.map(\.text) == ["A", "X", "B"])
    }

    @Test("established empty runs follow collapsed placement")
    func establishedEmptyRunsFollowCollapsedPlacement() throws
    {
        let sourceRuns = [
            SemanticRun(text: "A"),
            SemanticRun(text: ""),
            SemanticRun(text: "B")
        ]
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph(sourceRuns))
        ]
        let candidate = try Self.apply(
            text: "X",
            at: 1,
            blocks: blocks
        )
        let result = try #require(candidate)
        let runs = try Self.runs(in: result)

        #expect(runs.map(\.text) == ["A", "X", "", "B"])
    }
}
