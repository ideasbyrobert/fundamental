@testable import FundamentalParagraph
import Testing

@Suite
struct OwnedExactSpellingTests
{
    @Test
    func canonicalEqualityDoesNotAuthorizeChangedLookupUnits() throws
    {
        let lookup = try OwnedFixture.lookup("Café")
        let raw = PatternResult(
            identity: "synthetic", word: "cafe\u{301}", boundaries: [2],
            basis: .patterns, match: .init(weights: [], work: .init())
        )
        #expect(raw.word == lookup.text)
        #expect(!raw.word.utf16.elementsEqual(lookup.text.utf16))
        #expect(throws: OwnedCandidateFailure.changedSpelling)
        {
            try OwnedWordCandidates(
                lookup: lookup, result: raw, identity: "synthetic"
            )
        }
        try PatternEvidence.write(
            "canonical-spelling", group: "owned-corruption",
            record: OwnedEvidence.describe(.mappingRefused(
                lookup, raw, .changedSpelling
            ))
        )
    }
}
