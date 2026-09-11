package struct PatternTrie: Sendable
{
    package let nodes: [PatternTrieNode]
    package let maximumLength: Int

    package init(_ patterns: [WeightedPattern])
    {
        var nodes = [PatternTrieNode()]
        var maximumLength = 0
        for pattern in patterns
        {
            maximumLength = max(maximumLength, pattern.letters.count)
            var node = 0
            for letter in pattern.letters
            {
                if let child = nodes[node].edges[letter]
                {
                    node = child
                }
                else
                {
                    let child = nodes.count
                    nodes[node].edges[letter] = child
                    nodes.append(PatternTrieNode())
                    node = child
                }
            }
            switch nodes[node].terminal
            {
            case .branch:
                nodes[node].terminal = .weighted(pattern.weights)
            case let .weighted(previous):
                let merged = zip(previous, pattern.weights).map { max($0, $1) }
                nodes[node].terminal = .weighted(merged)
            }
        }
        self.nodes = nodes
        self.maximumLength = maximumLength
    }

    package func match(_ word: PatternWord) -> PatternMatch
    {
        let letters = [UInt32(46)] + word.scalars + [46]
        var weights = [UInt8](repeating: 0, count: letters.count + 1)
        var work = PatternWork()
        for start in letters.indices
        {
            var node = 0
            for position in start..<letters.count
            {
                work.edgeProbes += 1
                guard let child = nodes[node].edges[letters[position]]
                else
                {
                    break
                }
                node = child
                if case let .weighted(values) = nodes[node].terminal
                {
                    work.terminalMatches += 1
                    for (offset, value) in values.enumerated()
                    {
                        work.weightMerges += 1
                        weights[start + offset] = max(
                            weights[start + offset], value
                        )
                    }
                }
            }
        }
        return PatternMatch(weights: weights, work: work)
    }
}
