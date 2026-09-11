@testable import FundamentalParagraph
import Testing

enum OwnedFixture
{
    static func catalog() throws -> OwnedPatternCatalog
    {
        try OwnedPatternCatalog.bundled()
    }

    static func candidates(_ outcome: OwnedWordOutcome) throws
        -> OwnedWordCandidates
    {
        guard case let .candidates(value) = outcome
        else
        {
            Issue.record("Unexpected outcome: \(outcome)")
            throw WordFixtureFailure.invalidValue
        }
        return value
    }

    static func lookup(_ text: String, prefix: String = "") throws
        -> LowercaseWordLookup
    {
        let source = try WordFixture.source([WordFixture.run(prefix + text)])
        let range = prefix.utf16.count..<(prefix + text).utf16.count
        return try LowercaseWordLookup(NormalizedWordLookup(
            source: source.source, range: range
        ))
    }
}
