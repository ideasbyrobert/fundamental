enum ParagraphRangeSearch
{
    static func intersecting(
        _ query: Range<Int>, count: Int,
        interval: (Int) -> Range<Int>
    ) -> ParagraphRangeMatch
    {
        guard !query.isEmpty, count > 0
        else
        {
            return ParagraphRangeMatch(indices: 0..<0, comparisons: 0)
        }
        var comparisons = 0
        let lower = boundary(count, comparisons: &comparisons)
        {
            interval($0).upperBound <= query.lowerBound
        }
        let upper = boundary(count, comparisons: &comparisons)
        {
            interval($0).lowerBound < query.upperBound
        }
        return ParagraphRangeMatch(
            indices: lower..<upper, comparisons: comparisons
        )
    }

    private static func boundary(
        _ count: Int, comparisons: inout Int,
        before: (Int) -> Bool
    ) -> Int
    {
        var lower = 0
        var upper = count
        while lower < upper
        {
            let middle = lower + (upper - lower) / 2
            comparisons += 1
            if before(middle)
            {
                lower = middle + 1
            }
            else
            {
                upper = middle
            }
        }
        return lower
    }
}
