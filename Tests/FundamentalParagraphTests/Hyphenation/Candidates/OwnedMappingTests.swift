@testable import FundamentalParagraph
import FundamentalNativeParagraph
import Testing

@Suite
struct OwnedMappingTests
{
    @Test
    func corruptedEngineBoundariesRemainExplicitFailures() throws
    {
        let lookup = try OwnedFixture.lookup("İstanbul", prefix: "👩‍💻 ")
        let cases: [(String, [Int], OwnedCandidateFailure)] = [
            ("negative", [-1], .invalidBoundary(-1)),
            ("zero", [0], .invalidBoundary(0)),
            ("end", [9], .invalidBoundary(9)),
            ("beyond", [10], .invalidBoundary(10)),
            ("duplicate", [2, 2], .invalidBoundary(2)),
            ("reverse", [3, 2], .invalidBoundary(2)),
            ("grapheme", [1], .unmappedLowercase(1))
        ]
        for (name, boundaries, failure) in cases
        {
            let result = PatternResult(
                identity: "synthetic", word: lookup.text,
                boundaries: boundaries,
                basis: .patterns, match: .init(weights: [], work: .init())
            )
            #expect(throws: failure)
            {
                try OwnedWordCandidates(
                    lookup: lookup, result: result, identity: "synthetic"
                )
            }
            try PatternEvidence.write(
                name, group: "owned-corruption", record:
                    OwnedEvidence.describe(.mappingRefused(
                        lookup, result, failure
                    ))
            )
        }
        let result = PatternResult(
            identity: "synthetic", word: lookup.text, boundaries: [2],
            basis: .patterns, match: .init(weights: [], work: .init())
        )
        let value = try OwnedWordCandidates(
            lookup: lookup, result: result, identity: "synthetic"
        )
        #expect(value.candidates.map(\.sourceOffset) == [7])
    }

    @Test
    func changedIdentityOrExactSpellingRetainsTheRawResult() throws
    {
        let source = try WordFixture.source([WordFixture.run("Extraordinary")])
        let words = try NativeParagraphWords(source: source, language: .english)
        for identityChanged in [false, true]
        {
            let failure: OwnedCandidateFailure = identityChanged
                ? .changedIdentity : .changedSpelling
            let collection = try ParagraphOwnedCandidates(
                words, catalog: OwnedFixture.catalog()
            )
            {
                dictionary, text in
                PatternResult(
                    identity: identityChanged ? "wrong" : dictionary.identity,
                    word: identityChanged ? text : "different", boundaries: [2],
                    basis: .patterns, match: .init(weights: [], work: .init())
                )
            }
            let record = try #require(collection.records.first)
            guard case let .mappingRefused(lookup, raw, actual) = record.outcome
            else
            {
                throw WordFixtureFailure.invalidValue
            }
            #expect(actual == failure)
            #expect(lookup.normalized.sourceUTF16 == source.source.utf16)
            #expect(raw.boundaries == [2])
            try PatternEvidence.write(
                identityChanged ? "identity" : "spelling",
                group: "owned-corruption",
                record: OwnedEvidence.describe(record.outcome)
            )
        }
    }
}
