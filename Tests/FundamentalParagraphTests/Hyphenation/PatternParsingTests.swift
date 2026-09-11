@testable import FundamentalParagraph
import Testing

@Suite
struct PatternParsingTests
{
    @Test
    func parsesWeightsAndAnchorsWithoutChangingSpelling() throws
    {
        let pattern = try WeightedPattern(".a1b2c.")
        #expect(pattern.letters == [46, 97, 98, 99, 46])
        #expect(pattern.weights == [0, 0, 1, 2, 0, 0])
        #expect(pattern.spelling == ".a1b2c.")
        #expect(try WeightedPattern("9я").weights == [9, 0])
        #expect(try WeightedPattern("а\u{301}3б").weights == [0, 0, 3, 0])
    }

    @Test(arguments: ["", ".", "1", "a12b", "a.b", "a/b", "a b", "a!"])
    func malformedPatternsAreErrors(_ spelling: String) throws
    {
        #expect(throws: PatternFailure.invalidPattern(spelling))
        {
            try WeightedPattern(spelling)
        }
    }

    @Test
    func literalHyphensCarryWeightsLikeOtherPatternSymbols() throws
    {
        let pattern = try WeightedPattern("8-7")
        #expect(pattern.letters == [45])
        #expect(pattern.weights == [8, 7])
        #expect(try WeightedPattern("--8").weights == [0, 0, 8])
        #expect(try WeightedPattern(".а-8").weights == [0, 0, 0, 8])
        let dictionary = try PatternFixture.dictionary(
            #"\patterns{8-7 --8}"#
        )
        #expect(try dictionary.hyphenate("aa-bb").boundaries == [3])
        #expect(try dictionary.hyphenate("aa--bb").boundaries.isEmpty)
    }

    @Test
    func parsesOnlyTheRegisteredDataGrammar() throws
    {
        let source = """
        % ignored \\unknown{a1b}
        \\patterns{a1b % trailing comment
        b2c}
        \\hyphenation{ab-c present}
        """
        let data = try PatternData(source)
        #expect(data.patterns.map(\.spelling) == ["a1b", "b2c"])
        #expect(data.exceptions.map(\.word) == ["abc", "present"])
        #expect(data.exceptions.map(\.boundaries) == [[2], []])
        #expect(try PatternData(#"\patterns{}"#).patterns.isEmpty)
    }

    @Test(arguments: [
        "", #"\unknown{a1b}"#, #"\patterns a1b}"#, #"\patterns{a1b"#,
        #"\patterns{} \patterns{}"#, #"\hyphenation{ab-c}"#,
        #"\patterns{} trailing"#, #"\patterns{a{b}}"#
    ])
    func malformedDocumentsAreNeverPartlyAccepted(_ source: String) throws
    {
        #expect(throws: PatternFailure.self)
        {
            try PatternData(source)
        }
    }

    @Test(arguments: ["", "-abc", "abc-", "a--bc", "a.b", "a-\u{301}b"])
    func malformedExceptionsAreErrors(_ spelling: String) throws
    {
        #expect(throws: PatternFailure.invalidException(spelling))
        {
            try PatternException(spelling)
        }
    }
}
