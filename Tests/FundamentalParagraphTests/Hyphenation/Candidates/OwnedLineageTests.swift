@testable import FundamentalParagraph
import FundamentalNativeParagraph
import FundamentalDocument
import Testing

@Suite
struct OwnedLineageTests
{
    @Test(arguments: 1..<13, NativeWordScopeTests.allowedTraits)
    func everyStyleSeamKeepsOneOwnedWord(
        _ boundary: Int, _ traits: Set<SemanticInlineTrait>
    ) throws
    {
        let characters = Array("Extraordinary")
        let source = try WordFixture.source([
            WordFixture.run(String(characters[..<boundary]), traits: traits),
            WordFixture.run(String(characters[boundary...]))
        ])
        let names = traits.map(\.rawValue).sorted().joined(separator: "-")
        let experiment = try OwnedEvidence.observe(
            "split-\(boundary)-" + names, source: source
        )
        #expect(experiment.requests.count == 1)
        #expect(experiment.collection.records.count == 1)
        let record = try #require(experiment.collection.records.first)
        let value = try OwnedFixture.candidates(record.outcome)
        #expect(value.candidates.map(\.sourceOffset) == [2, 5, 7, 9])
        #expect(value.lookup.normalized.sourceUTF16
            == Array("Extraordinary".utf16))
        let scope = try WordFixture.resolved(record.word.resolution)
        #expect(scope.fragments == [
            .init(runIndex: 0, paragraphRange: 0..<boundary,
                  runRange: 0..<boundary),
            .init(runIndex: 1, paragraphRange: boundary..<13,
                  runRange: 0..<(13 - boundary))
        ])
        #expect(experiment.collection.words.source.paragraph
            == source.paragraph)
    }

    @Test(arguments: [false, true])
    func capitalizedRussianKeepsItsOriginalCombiningSeam(
        _ decomposed: Bool
    ) throws
    {
        let left = decomposed ? "Раи" : "Ра"
        let right = decomposed ? "\u{306}он" : "йон"
        let source = try WordFixture.source([
            WordFixture.run("👩‍💻 "),
            WordFixture.run(left, traits: [.strong]),
            WordFixture.run(right, traits: [.emphasis]),
            WordFixture.run("!")
        ], language: "ru_RU")
        let experiment = try OwnedEvidence.observe(
            decomposed ? "russian-nfd" : "russian-nfc",
            source: source, language: .russian
        )
        let records = try experiment.collection.matching(6..<6)
        let record = try #require(records.first)
        let value = try OwnedFixture.candidates(record.outcome)
        #expect(value.lookup.text == "район")
        #expect(value.lookup.normalized.sourceUTF16
            == Array((left + right).utf16))
        #expect(value.candidates.map(\.sourceOffset) == [decomposed ? 10 : 9])
        #expect(value.candidates.map(\.lookupOffset) == [3])
        #expect(experiment.requests.count == 1)
        let scope = try WordFixture.resolved(record.word.resolution)
        #expect(scope.fragments.map(\.runIndex) == [1, 2])
        #expect(value.candidates[0].sourceOffset
            - scope.fragments[1].paragraphRange.lowerBound == 1)
        if decomposed
        {
            #expect(throws: WordScopeFailure.invalidQuery(9..<9))
            {
                try experiment.collection.matching(9..<9)
            }
        }
    }
}
