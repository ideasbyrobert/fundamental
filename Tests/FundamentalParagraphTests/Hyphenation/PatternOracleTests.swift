@testable import FundamentalParagraph
import Testing

@Suite
struct PatternOracleTests
{
    @Test
    func exhaustiveWordsAgreeWithLinearOracleAndReversedInsertion() throws
    {
        let spellings = [
            "a1b", "ab2c", "b3c", "bc3", ".a2b", "c4a.", "a2b", "a5b",
            "b1b", ".b3", "c1c", "ab3a", "ba4b", "c5ab"
        ]
        let data = try PatternData(
            "\\patterns{" + spellings.joined(separator: " ") + "}"
        )
        let reversed = try PatternData(
            "\\patterns{" + spellings.reversed().joined(separator: " ") + "}"
        )
        let first = PatternTrie(data.patterns)
        let second = PatternTrie(reversed.patterns)
        var words = [""]
        var layer = [""]
        for _ in 0..<6
        {
            layer = layer.flatMap
            {
                prefix in
                ["a", "b", "c"].map { prefix + $0 }
            }
            words.append(contentsOf: layer)
        }
        #expect(words.count == 1093)
        #expect(Set(words).count == 1093)
        var observations: [[String: Any]] = []
        for text in words
        {
            let word = try PatternWord(text)
            let actual = first.match(word)
            let reordered = second.match(word)
            let oracle = LinearPatternOracle(
                patterns: data.patterns, text: text
            )
            #expect(actual.weights == oracle.weights)
            #expect(actual == reordered)
            let bound = (word.scalars.count + 2) * (first.maximumLength + 1)
            #expect(actual.work.edgeProbes <= bound)
            observations.append([
                "word": text, "actual": actual.weights,
                "linear": oracle.weights,
                "edgeProbes": actual.work.edgeProbes, "bound": bound
            ])
        }
        try PatternEvidence.write(
            "exhaustive", group: "oracle", record: [
                "words": observations, "count": words.count,
                "patternCount": spellings.count
            ]
        )
    }
}
