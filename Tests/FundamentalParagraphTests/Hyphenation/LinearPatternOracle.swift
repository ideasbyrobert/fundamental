@testable import FundamentalParagraph
struct LinearPatternOracle
{
    let weights: [UInt8]
    let visitedPatterns: Int
    let symbolComparisons: Int

    init(patterns: [WeightedPattern], text: String)
    {
        let letters = [UInt32(46)] + text.unicodeScalars.map(\.value) + [46]
        var weights = [UInt8](repeating: 0, count: letters.count + 1)
        var visited = 0
        var comparisons = 0
        for pattern in patterns
        {
            visited += 1
            if pattern.letters.count > letters.count
            {
                continue
            }
            for start in 0...(letters.count - pattern.letters.count)
            {
                var agrees = true
                for offset in pattern.letters.indices
                {
                    comparisons += 1
                    if letters[start + offset] != pattern.letters[offset]
                    {
                        agrees = false
                        break
                    }
                }
                if agrees
                {
                    for boundary in pattern.weights.indices
                    {
                        let value = pattern.weights[boundary]
                        if value > weights[start + boundary]
                        {
                            weights[start + boundary] = value
                        }
                    }
                }
            }
        }
        self.weights = weights
        visitedPatterns = visited
        symbolComparisons = comparisons
    }
}
