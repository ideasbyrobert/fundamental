import Testing

@testable import FundamentalDocument

extension AppliedSemanticTextDeletionTests
{
    @Test("within-run deletion retains exact scoped fragments")
    func withinRunDeletionRetainsScopedFragments() throws
    {
        let scope = try #require(SemanticRunAttributesTests.scopes().last)
        let attributes = SemanticRunAttributes.scoped(
            traits: [.strong],
            scopes: scope
        )
        let run = SemanticRun(text: "ABCDE", attributes: attributes)
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([run]))
        ]
        let candidate = try Self.apply(
            start: 1,
            end: 4,
            blocks: blocks
        )
        let result = try #require(candidate)

        #expect(try Self.runs(in: result) == [
            SemanticRun(text: "A", attributes: attributes),
            SemanticRun(text: "E", attributes: attributes)
        ])
    }

    @Test("cross-run deletion retains each surviving attribute")
    func crossRunDeletionRetainsSurvivingAttributes() throws
    {
        let direct = SemanticRunAttributes.direct(traits: [.emphasis])
        let scope = try #require(SemanticRunAttributesTests.scopes().first)
        let scoped = SemanticRunAttributes.scoped(
            traits: [.inlineCode],
            scopes: scope
        )
        let blocks: [(UInt8, SemanticBlock)] = [
            (2, Self.paragraph([
                SemanticRun(text: "AB", attributes: direct),
                SemanticRun(text: "CD", attributes: scoped)
            ]))
        ]
        let candidate = try Self.apply(
            start: 1,
            end: 3,
            blocks: blocks
        )
        let result = try #require(candidate)

        #expect(try Self.runs(in: result) == [
            SemanticRun(text: "A", attributes: direct),
            SemanticRun(text: "D", attributes: scoped)
        ])
    }

    @Test("empty runs follow the half-open partition law")
    func emptyRunsFollowPartitionLaw() throws
    {
        let sourceRuns = [
            SemanticRun(text: ""),
            SemanticRun(text: "A"),
            SemanticRun(text: ""),
            SemanticRun(text: "B"),
            SemanticRun(text: ""),
            SemanticRun(text: "C"),
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
            "", "A", "", "C", ""
        ])
    }
}
