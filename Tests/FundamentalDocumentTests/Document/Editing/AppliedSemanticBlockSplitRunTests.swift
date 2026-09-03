import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockSplitTests
{
    @Test("empty runs obey the collapsed half-open partition law")
    func emptyRunsObeyCollapsedPartitionLaw() throws
    {
        let before = SemanticRun(text: "", traits: [.strong])
        let atPoint = SemanticRun(text: "", traits: [.emphasis])
        let after = SemanticRun(text: "", traits: [.inlineCode])
        let runs = [
            before,
            SemanticRun(text: "AB"),
            atPoint,
            SemanticRun(text: "CD"),
            after
        ]
        let source = try Self.document(blocks: [
            (2, Self.paragraph(runs))
        ])
        let candidate = try Self.apply(at: 2, in: source)
        let result = try #require(candidate)

        #expect(try Self.runs(in: result, at: 0) == Array(runs[0 ... 1]))
        #expect(try Self.runs(in: result, at: 1) == Array(runs[2 ... 4]))
    }

    @Test("an established run boundary remains established")
    func establishedRunBoundaryRemainsEstablished() throws
    {
        let first = SemanticRun(text: "A", traits: [.strong])
        let second = SemanticRun(text: "B", traits: [.strong])
        let source = try Self.document(blocks: [
            (2, Self.paragraph([first, second]))
        ])
        let candidate = try Self.apply(at: 1, in: source)
        let result = try #require(candidate)

        #expect(try Self.runs(in: result, at: 0) == [first])
        #expect(try Self.runs(in: result, at: 1) == [second])

        let crossRun = try Self.document(blocks: [
            (2, Self.paragraph([
                SemanticRun(text: "e"),
                SemanticRun(text: "\u{301}"),
                SemanticRun(text: "X")
            ]))
        ])
        let crossRunCandidate = try Self.apply(at: 2, in: crossRun)
        let crossRunResult = try #require(crossRunCandidate)

        #expect(try Self.runs(in: crossRunResult, at: 0).map(\.text) == [
            "e", "\u{301}"
        ])
        #expect(try Self.runs(in: crossRunResult, at: 1).map(\.text) == ["X"])
    }

    @Test("direct and scoped attributes remain exact")
    func directAndScopedAttributesRemainExact() throws
    {
        let scopes = try SemanticRunAttributesTests.scopes()
        let attributes: [SemanticRunAttributes] = [
            .direct(traits: [.strong])
        ] + scopes.map { .scoped(traits: [.emphasis], scopes: $0) }

        for attribute in attributes
        {
            let run = SemanticRun(text: "AB", attributes: attribute)
            let source = try Self.document(blocks: [
                (2, Self.paragraph([run]))
            ])
            let candidate = try Self.apply(at: 1, in: source)
            let result = try #require(candidate)
            let expectedPrefix = SemanticRun(
                text: "A",
                attributes: attribute
            )
            let expectedSuffix = SemanticRun(
                text: "B",
                attributes: attribute
            )

            #expect(try Self.runs(in: result, at: 0) == [expectedPrefix])
            #expect(try Self.runs(in: result, at: 1) == [expectedSuffix])
        }
    }
}
