extension NormalizedWordLookup
{
    package func sourceOffset(at lookup: Int) throws(HyphenationFailure) -> Int
    {
        try offset(
            lookup, from: \.lookup, to: \.source,
            failure: .unmappedLookup(lookup)
        )
    }

    package func lookupOffset(at source: Int) throws(HyphenationFailure) -> Int
    {
        try offset(
            source, from: \.source, to: \.lookup,
            failure: .unmappedSource(source)
        )
    }

    private func offset(
        _ value: Int, from: KeyPath<HyphenationBoundary, Int>,
        to: KeyPath<HyphenationBoundary, Int>,
        failure: HyphenationFailure
    ) throws(HyphenationFailure) -> Int
    {
        var lower = 0
        var upper = boundaries.count
        while lower < upper
        {
            let middle = lower + (upper - lower) / 2
            if boundaries[middle][keyPath: from] < value
            {
                lower = middle + 1
            }
            else
            {
                upper = middle
            }
        }
        guard lower < boundaries.count,
              boundaries[lower][keyPath: from] == value
        else
        {
            throw failure
        }
        return boundaries[lower][keyPath: to]
    }
}
