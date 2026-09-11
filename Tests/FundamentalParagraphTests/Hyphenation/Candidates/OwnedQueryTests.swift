@testable import FundamentalParagraph
import FundamentalNativeParagraph
import Testing

@Suite
struct OwnedQueryTests
{
    @Test
    func repeatedQueriesDoNotReenterTheEngine() throws
    {
        let source = try WordFixture.source([WordFixture.run("Extraordinary")])
        let words = try NativeParagraphWords(source: source, language: .english)
        var requests = 0
        let collection = try ParagraphOwnedCandidates(
            words, catalog: OwnedFixture.catalog()
        )
        {
            dictionary, text in
            requests += 1
            return try dictionary.hyphenate(text)
        }
        #expect(requests == 1)
        let queries = [0..<13, 1..<2, 2..<2, 13..<13]
        for query in queries
        {
            _ = try collection.matching(query)
        }
        #expect(requests == 1)
        try PatternEvidence.write(
            "queries", group: "owned-work", record: [
                "queries": queries.map { [$0.lowerBound, $0.upperBound] },
                "engineCalls": requests
            ]
        )
    }

    @Test
    func nativeGraphemeRefusalRemainsVisibleBesideProtectedWords() throws
    {
        let source = try WordFixture.source([
            WordFixture.run("alpha\u{A0}beta no\u{2060}break a\u{200D}b")
        ])
        let experiment = try OwnedEvidence.observe(
            "unsafe-joiner", source: source
        )
        let records = try experiment.collection.matching(20..<22)
        #expect(records.map(\.word.resolution) == [
            .refused(20..<21, [.graphemeBoundary])
        ])
        let record = try #require(records.first)
        guard case .sourceRefused = record.outcome
        else
        {
            throw WordFixtureFailure.invalidValue
        }
        #expect(experiment.requests.map(\.word) == ["alpha", "beta"])
    }
}
