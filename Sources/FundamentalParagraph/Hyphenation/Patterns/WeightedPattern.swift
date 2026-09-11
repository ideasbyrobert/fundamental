package struct WeightedPattern: Equatable, Sendable
{
    package let spelling: String
    package let letters: [UInt32]
    package let weights: [UInt8]

    package init(_ spelling: String) throws(PatternFailure)
    {
        var letters: [UInt32] = []
        var weights: [UInt8] = [0]
        var previousWasWeight = false
        for scalar in spelling.unicodeScalars
        {
            if (48...57).contains(scalar.value)
            {
                guard !previousWasWeight
                else
                {
                    throw .invalidPattern(spelling)
                }
                weights[weights.count - 1] = UInt8(scalar.value - 48)
                previousWasWeight = true
            }
            else
            {
                guard scalar.value == 45 || scalar.value == 46
                    || Self.isLetter(scalar)
                else
                {
                    throw .invalidPattern(spelling)
                }
                letters.append(scalar.value)
                weights.append(0)
                previousWasWeight = false
            }
        }
        guard letters.contains(where: { $0 != 46 })
        else
        {
            throw .invalidPattern(spelling)
        }
        for (index, letter) in letters.enumerated()
        {
            guard letter != 46 || index == 0 || index == letters.count - 1
            else
            {
                throw .invalidPattern(spelling)
            }
        }
        self.spelling = spelling
        self.letters = letters
        self.weights = weights
    }

    package static func isLetter(_ scalar: Unicode.Scalar) -> Bool
    {
        scalar.properties.isAlphabetic
            || scalar.properties.generalCategory == .nonspacingMark
            || scalar.properties.generalCategory == .spacingMark
            || scalar.properties.generalCategory == .enclosingMark
    }
}
