package struct PatternException: Equatable, Sendable
{
    package let spelling: String
    package let word: String
    package let boundaries: [Int]

    package init(_ spelling: String) throws(PatternFailure)
    {
        var word = ""
        var boundaries: [Int] = []
        var offset = 0
        var previousWasHyphen = false
        for scalar in spelling.unicodeScalars
        {
            if scalar.value == 45
            {
                guard offset > 0, !previousWasHyphen
                else
                {
                    throw .invalidException(spelling)
                }
                boundaries.append(offset)
                previousWasHyphen = true
            }
            else
            {
                guard WeightedPattern.isLetter(scalar)
                else
                {
                    throw .invalidException(spelling)
                }
                word.unicodeScalars.append(scalar)
                offset += scalar.utf16.count
                previousWasHyphen = false
            }
        }
        guard !word.isEmpty, !previousWasHyphen
        else
        {
            throw .invalidException(spelling)
        }
        let input = try PatternWord(word)
        let complete = Set(input.boundaries.map(\.utf16))
        guard boundaries.allSatisfy(complete.contains)
        else
        {
            throw .invalidException(spelling)
        }
        self.spelling = spelling
        self.word = word
        self.boundaries = boundaries
    }
}
