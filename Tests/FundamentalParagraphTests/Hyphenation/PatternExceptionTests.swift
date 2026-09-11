@testable import FundamentalParagraph
import Testing

@Suite
struct PatternExceptionTests
{
    @Test(arguments: PatternFixture.languages)
    func allExceptionsHonorTheirExplicitWholeCharacterBoundaries(
        _ locale: String
    ) throws
    {
        let resource = try PatternFixture.resource(locale)
        let dictionary = try resource.dictionary(
            from: PatternFixture.directory()
        )
        let exceptions = try PatternFixture.tokens(resource, suffix: "hyp")
        var observations: [[String: Any]] = []
        for spelling in exceptions
        {
            let pieces = spelling.split(
                separator: "-", omittingEmptySubsequences: false
            )
            let word = pieces.joined()
            var prefix = ""
            var expected: [Int] = []
            for piece in pieces.dropLast()
            {
                prefix.append(contentsOf: piece)
                if prefix.count >= resource.left,
                   word.count - prefix.count >= resource.right
                {
                    expected.append(prefix.utf16.count)
                }
            }
            let result = try dictionary.hyphenate(word)
            #expect(result.basis == .exception)
            #expect(result.boundaries == expected)
            #expect(result.word.utf16.elementsEqual(word.utf16))
            #expect(result.match.work.edgeProbes == 0)
            observations.append([
                "exception": spelling, "expected": expected,
                "actual": PatternEvidence.describe(result)
            ])
        }
        try PatternEvidence.write(
            "exceptions-" + locale, group: "observations",
            record: ["exceptions": observations]
        )
    }
}
