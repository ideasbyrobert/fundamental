import Testing

@testable import FundamentalDocument

extension AppliedSemanticBlockSplitTests
{
    @Test("a middle split produces exact adjacent fragments")
    func middleSplitProducesExactAdjacentFragments() throws
    {
        let examples = [
            ("ABCD", 2, "AB", "CD"),
            ("e\u{301}X", 2, "e\u{301}", "X"),
            ("किX", 2, "कि", "X"),
            ("\u{2708}\u{FE0F}X", 2, "\u{2708}\u{FE0F}", "X"),
            ("👩‍💻X", 5, "👩‍💻", "X"),
            ("🇦🇲X", 4, "🇦🇲", "X"),
            ("👍🏽X", 4, "👍🏽", "X")
        ]
        for example in examples
        {
            let source = try Self.document(blocks: [
                (2, Self.paragraph([SemanticRun(text: example.0)]))
            ])
            let candidate = try Self.apply(at: example.1, in: source)
            let result = try #require(candidate)

            #expect(Self.scalarValues(try Self.text(in: result, at: 0)) ==
                Self.scalarValues(example.2))
            #expect(Self.scalarValues(try Self.text(in: result, at: 1)) ==
                Self.scalarValues(example.3))
            #expect(result.document.content.blocks.count == 2)
        }
    }

    @Test("a start split leaves a runless prefix")
    func startSplitLeavesRunlessPrefix() throws
    {
        let run = SemanticRun(text: "AB")
        let source = try Self.document(blocks: [
            (2, Self.paragraph([run]))
        ])
        let candidate = try Self.apply(at: 0, in: source)
        let result = try #require(candidate)

        #expect(try Self.runs(in: result, at: 0).isEmpty)
        #expect(try Self.runs(in: result, at: 1) == [run])
    }

    @Test("an end split leaves a runless continuation")
    func endSplitLeavesRunlessContinuation() throws
    {
        let run = SemanticRun(text: "AB")
        let source = try Self.document(blocks: [
            (2, Self.paragraph([run]))
        ])
        let candidate = try Self.apply(at: 2, in: source)
        let result = try #require(candidate)

        #expect(try Self.runs(in: result, at: 0) == [run])
        #expect(try Self.runs(in: result, at: 1).isEmpty)
    }

    @Test("a runless block splits into two runless blocks")
    func runlessBlockSplitsIntoTwoRunlessBlocks() throws
    {
        let source = try Self.document(blocks: [
            (2, Self.paragraph([]))
        ])
        let candidate = try Self.apply(at: 0, in: source)
        let result = try #require(candidate)

        #expect(try Self.runs(in: result, at: 0).isEmpty)
        #expect(try Self.runs(in: result, at: 1).isEmpty)
        #expect(result.caret.runPosition == .noRuns)
    }
}
