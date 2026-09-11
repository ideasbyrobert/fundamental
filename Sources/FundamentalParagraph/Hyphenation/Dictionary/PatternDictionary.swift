package struct PatternDictionary: Sendable
{
    package let identity: String
    package let minima: PatternMinima
    package let trie: PatternTrie
    package let exceptions: [[UInt32]: [Int]]

    package init(
        identity: String, data: PatternData, minima: PatternMinima
    ) throws(PatternFailure)
    {
        var exceptions: [[UInt32]: [Int]] = [:]
        for exception in data.exceptions
        {
            let key = exception.word.unicodeScalars.map(\.value)
            if let previous = exceptions[key], previous != exception.boundaries
            {
                throw .conflictingException(exception.word)
            }
            exceptions[key] = exception.boundaries
        }
        self.identity = identity
        self.minima = minima
        trie = PatternTrie(data.patterns)
        self.exceptions = exceptions
    }

    package func hyphenate(_ text: String) throws(PatternFailure)
        -> PatternResult
    {
        let word = try PatternWord(text)
        let count = word.boundaries.count - 1
        if let exception = exceptions[word.scalars]
        {
            let allowed = Set(exception)
            let boundaries = word.boundaries.enumerated().filter
            {
                minima.allows($0.offset, count: count)
                    && allowed.contains($0.element.utf16)
            }.map(\.element.utf16)
            return PatternResult(
                identity: identity, word: text, boundaries: boundaries,
                basis: .exception,
                match: PatternMatch(weights: [], work: PatternWork())
            )
        }
        let match = trie.match(word)
        let boundaries = word.boundaries.enumerated().filter
        {
            minima.allows($0.offset, count: count)
                && match.weights[$0.element.scalar + 1] % 2 == 1
        }.map(\.element.utf16)
        return PatternResult(
            identity: identity, word: text, boundaries: boundaries,
            basis: .patterns, match: match
        )
    }
}
