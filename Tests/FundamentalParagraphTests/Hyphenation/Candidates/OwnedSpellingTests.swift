@testable import FundamentalParagraph
import Testing

@Suite
struct OwnedSpellingTests
{
    @Test
    func capitalizationIsADeclaredPolicyInsteadOfNativeTokenFlags() throws
    {
        let source = try WordFixture.source([
            WordFixture.run(
                "extraordinary Extraordinary EXTRAORDINARY eXtraordinary "
            ),
            WordFixture.scoped(
                "район Район ЮНЕСКО КамАЗ",
                .language(WordFixture.language("ru_RU"))
            )
        ])
        let experiment = try OwnedEvidence.observe(
            "capitalization", source: source
        )
        #expect(experiment.collection.records.count == 8)
        #expect(experiment.requests.count == 4)
        let records = experiment.collection.records
        #expect(records.map(\.word.flags) == Array(repeating: 0, count: 8))
        for index in [0, 1, 4, 5]
        {
            let value = try OwnedFixture.candidates(records[index].outcome)
            #expect(!value.candidates.isEmpty)
        }
        let refusals: [(Int, OwnedCapitalization)] = [
            (2, .allCapitals), (3, .mixed), (6, .allCapitals), (7, .mixed)
        ]
        for (index, expected) in refusals
        {
            guard case let .capitalizationRefused(actual) =
                records[index].outcome
            else
            {
                throw WordFixtureFailure.invalidValue
            }
            #expect(actual == expected)
        }
    }

    @Test(arguments: [
        "en-US", "en", "en_AU", "EN_US", "ru", "zz_ZZ", "en_US_POSIX"
    ])
    func unknownIdentifiersNeverChooseADictionary(_ language: String) throws
    {
        let source = try WordFixture.source(
            [WordFixture.run("extraordinary")], language: language
        )
        let experiment = try OwnedEvidence.observe(
            "locale-" + language, source: source
        )
        #expect(experiment.requests.isEmpty)
        #expect(experiment.collection.records.count == 1)
        let record = try #require(experiment.collection.records.first)
        guard case let .unsupportedLanguage(requested) = record.outcome
        else
        {
            throw WordFixtureFailure.invalidValue
        }
        #expect(requested.utf16.elementsEqual(language.utf16))
    }

    @Test(arguments: ["район", "İstanbul", "café", "абзац"])
    func unsupportedAlphabetIsNotASuccessfulEmptyResult(_ text: String) throws
    {
        let experiment = try OwnedEvidence.observe(
            "alphabet-" + OwnedEvidence.spellingName(text),
            source: WordFixture.source([WordFixture.run(text)])
        )
        #expect(experiment.requests.isEmpty)
        #expect(experiment.collection.records.count == 1)
        let record = try #require(experiment.collection.records.first)
        guard case .unsupportedAlphabet(.american) = record.outcome
        else
        {
            throw WordFixtureFailure.invalidValue
        }
    }
}
