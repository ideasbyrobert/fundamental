@testable import FundamentalParagraph
import Testing

@Suite
struct PatternCorpusTests
{
    @Test(arguments: PatternFixture.languages)
    func comparesRealLanguageCandidatesAndBoundedWork(_ locale: String) throws
    {
        let resource = try PatternFixture.resource(locale)
        let root = try PatternFixture.directory()
        let data = try resource.load(from: root)
        let dictionary = try resource.dictionary(from: root)
        var observations: [[String: Any]] = []
        var work: [[String: Any]] = []
        for text in PatternFixture.words
        {
            let word = try PatternWord(text)
            let actual = dictionary.trie.match(word)
            let oracle = LinearPatternOracle(
                patterns: data.patterns, text: text
            )
            #expect(actual.weights == oracle.weights)
            let result = try dictionary.hyphenate(text)
            if result.basis == .patterns
            {
                #expect(result.match == actual)
                let expected = word.boundaries.enumerated().filter
                {
                    $0.offset >= resource.left
                        && countAfter($0.offset, in: word) >= resource.right
                        && oracle.weights[$0.element.scalar + 1] % 2 == 1
                }.map(\.element.utf16)
                #expect(result.boundaries == expected)
            }
            let bound = (word.scalars.count + 2)
                * (dictionary.trie.maximumLength + 1)
            #expect(actual.work.edgeProbes <= bound)
            #expect(oracle.visitedPatterns == data.patterns.count)
            #expect(oracle.visitedPatterns > bound)
            observations.append(PatternEvidence.describe(result))
            work.append([
                "word": text, "edgeProbes": actual.work.edgeProbes,
                "bound": bound, "weightMerges": actual.work.weightMerges,
                "linearPatternVisits": oracle.visitedPatterns,
                "linearSymbolComparisons": oracle.symbolComparisons
            ])
        }
        #expect(observations.count == 29)
        try PatternEvidence.write("corpus-" + locale, group: "observations",
                                  record: ["results": observations])
        try PatternEvidence.write(locale, group: "work", record: [
            "identity": dictionary.identity, "words": work
        ])
    }

    @Test
    func retainsThePublishedDemocratCounterexample() throws
    {
        let resource = try PatternFixture.resource("en_US")
        let dictionary = try resource.dictionary(
            from: PatternFixture.directory()
        )
        #expect(try dictionary.hyphenate("democrat").boundaries == [2, 4, 5])
    }

    private func countAfter(_ index: Int, in word: PatternWord) -> Int
    {
        word.boundaries.count - 1 - index
    }
}
