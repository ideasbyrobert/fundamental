extension ParagraphWordSource
{
    package func fragments(in range: Range<Int>) -> ParagraphFragmentQuery
    {
        let match = ParagraphRangeSearch.intersecting(
            range, count: occupiedSpans.count
        )
        {
            occupiedSpans[$0].range
        }
        var fragments: [WordRunFragment] = []
        var visited = 0
        for index in match.indices
        {
            let span = occupiedSpans[index]
            visited += 1
            let lower = max(range.lowerBound, span.range.lowerBound)
            let upper = min(range.upperBound, span.range.upperBound)
            if lower < upper
            {
                let localLower = lower - span.range.lowerBound
                let localUpper = upper - span.range.lowerBound
                fragments.append(WordRunFragment(
                    runIndex: span.index,
                    paragraphRange: lower..<upper,
                    runRange: localLower..<localUpper
                ))
            }
        }
        return ParagraphFragmentQuery(
            fragments: fragments, searchComparisons: match.comparisons,
            visitedRuns: visited
        )
    }
}
