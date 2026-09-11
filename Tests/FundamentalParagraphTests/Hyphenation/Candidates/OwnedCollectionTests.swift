@testable import FundamentalParagraph
import FundamentalNativeParagraph
import Testing

@Suite
struct OwnedCollectionTests
{
    @Test
    func routesEachSemanticWordAndFiltersWithoutMoreWork() throws
    {
        let us = try WordFixture.language("en_US")
        let gb = try WordFixture.language("en_GB")
        let ru = try WordFixture.language("ru_RU")
        let source = try WordFixture.source([
            WordFixture.scoped("Extraordinary", .language(us)),
            WordFixture.run(" "),
            WordFixture.scoped("Extraordinary", .language(gb)),
            WordFixture.run(" "),
            WordFixture.scoped("Район", .language(ru))
        ])
        let experiment = try OwnedEvidence.observe("mixed", source: source)
        let collection = experiment.collection
        let expected = [[2, 5, 7, 9], [16, 24], [31]]
        for (record, offsets) in zip(collection.records, expected)
        {
            let result = try OwnedFixture.candidates(record.outcome)
            #expect(result.candidates.map(\.sourceOffset) == offsets)
            #expect(result.candidates.allSatisfy { $0.hyphenScalar == 0x2010 })
        }
        #expect(collection.records.count == 3)
        #expect(experiment.requests.count == 3)
        #expect(try collection.matching(1..<2).map(\.word.resolution.range)
            == [0..<13])
        #expect(try collection.matching(2..<2).count == 1)
        #expect(try collection.matching(13..<14).isEmpty)
        #expect(try collection.matching(33..<33).isEmpty)
        #expect(throws: WordScopeFailure.invalidQuery(33..<34))
        {
            try collection.matching(33..<34)
        }
        #expect(collection.words.source.paragraph == source.paragraph)
        #expect(collection.words.returnedUTF16 == source.source.utf16)
        #expect(experiment.requests.map(\.word)
            == ["extraordinary", "extraordinary", "район"])
    }

    @Test
    func emptyAndShortWordsKeepDifferentSuccessfulResults() throws
    {
        let empty = try OwnedEvidence.observe(
            "empty", source: WordFixture.source([WordFixture.run("")])
        )
        #expect(empty.collection.records.isEmpty)
        #expect(empty.requests.isEmpty)
        let short = try OwnedEvidence.observe(
            "short", source: WordFixture.source([WordFixture.run("a")])
        )
        #expect(short.requests.count == 1)
        let record = try #require(short.collection.records.first)
        #expect(try OwnedFixture.candidates(record.outcome).candidates.isEmpty)
    }
}
