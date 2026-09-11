@testable import FundamentalParagraph
@testable import FundamentalNativeParagraph
import Testing

@MainActor
@Suite
struct AutomaticPolicyTests
{
    @Test
    func existingRefusalsCannotAcquireAutomaticInk() throws
    {
        let sources = [
            try ExplicitFixture.source("EXTRAORDINARY"),
            try ExplicitFixture.source("extra\u{AD}ordinary"),
            try ExplicitFixture.source("extraordinary", language: "zz_ZZ"),
            try WordFixture.source([
                WordFixture.run("extraordinary", traits: [.inlineCode])
            ])
        ]
        for (index, source) in sources.enumerated()
        {
            let value = try AutomaticFixture.collection(source)
            #expect(!value.automatic.records.isEmpty)
            #expect(value.inks.isEmpty)
            #expect(throws: AutomaticInkFailure.invalidIndex(0))
            {
                try value.selectAutomatic(0)
            }
            let line = try AutomaticFixture.line(
                value, range: source.source.utf16.indices
            )
            try AutomaticEvidence.write(
                "policy-" + String(index), collection: value, lines: [line]
            )
        }
    }

    @Test
    func malformedBackendResultsRemainRefused() throws
    {
        let source = try ExplicitFixture.source("extraordinary")
        for kind in ["identity", "spelling", "boundary"]
        {
            let value = try ParagraphHyphens(
                NativeParagraphWords(source: source, language: .english),
                catalog: OwnedFixture.catalog()
            )
            {
                dictionary, text in
                PatternResult(
                    identity: kind == "identity"
                        ? "wrong" : dictionary.identity,
                    word: kind == "spelling" ? "different" : text,
                    boundaries: kind == "boundary" ? [0] : [2],
                    basis: .patterns, match: .init(weights: [], work: .init())
                )
            }
            #expect(value.inks.isEmpty)
            let first = try #require(value.automatic.records.first)
            guard case .mappingRefused = first.outcome
            else
            {
                Issue.record("Malformed backend result was not retained")
                continue
            }
            #expect(throws: AutomaticInkFailure.invalidIndex(0))
            {
                try value.selectAutomatic(0)
            }
            try AutomaticEvidence.write(
                "malformed-" + kind, collection: value, lines: []
            )
        }
    }
}
