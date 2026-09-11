@testable import FundamentalParagraph
import FundamentalNativeParagraph
import Testing

@Suite
struct NativeWordQueryTests
{
    @Test
    func filtersFullTokensAfterParagraphEnumeration() throws
    {
        let source = try WordFixture.source([
            WordFixture.run("👩‍💻 extra", traits: [.strong]),
            WordFixture.run("ordinary!")
        ])
        let words = try WordEvidence.observe("prefixed-query", source: source)
        for query in [8..<13, 8..<8, 6..<6, 6..<19]
        {
            let selected = try words.matching(query)
            #expect(selected.map(\.resolution.range) == [6..<19])
            let first = try #require(selected.first)
            let scope = try WordFixture.resolved(first.resolution)
            #expect(scope.fragments == [
                .init(runIndex: 0, paragraphRange: 6..<11, runRange: 6..<11),
                .init(runIndex: 1, paragraphRange: 11..<19, runRange: 0..<8)
            ])
        }
        #expect(try words.matching(5..<6).isEmpty)
        #expect(try words.matching(19..<19).isEmpty)
        #expect(try words.matching(20..<20).isEmpty)
        for query in [-1..<0, 0..<21, 0..<Int.max, 1..<2, 2..<2]
        {
            #expect(throws: WordScopeFailure.invalidQuery(query))
            {
                try words.matching(query)
            }
        }
    }

    @Test
    func keepsHalfOpenWordAndQueryEdges() throws
    {
        let source = try WordFixture.source([WordFixture.run("first second")])
        let words = try WordEvidence.observe("query-edges", source: source)
        #expect(try words.matching(0..<6).map(\.resolution.range) == [0..<5])
        #expect(try words.matching(5..<7).map(\.resolution.range) == [6..<12])
        #expect(try words.matching(5..<5).isEmpty)
        #expect(try words.matching(6..<6).map(\.resolution.range) == [6..<12])
        #expect(try words.matching(12..<12).isEmpty)
    }

    @Test
    func emptyParagraphProducesNoTokensOrQueryMatches() throws
    {
        let words = try WordEvidence.observe(
            "empty", source: WordFixture.source([])
        )
        #expect(words.observations.isEmpty)
        #expect(words.returnedUTF16.isEmpty)
        #expect(try words.matching(0..<0).isEmpty)
    }
}
