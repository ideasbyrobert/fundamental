extension ParagraphWordSource
{
    package func endings(in range: Range<Int>) -> ParagraphEndingQuery
    {
        let match = ParagraphRangeSearch.intersecting(
            range, count: hardEndings.count
        )
        {
            hardEndings[$0]
        }
        var endings: [Range<Int>] = []
        var visited = 0
        for index in match.indices
        {
            endings.append(hardEndings[index])
            visited += 1
        }
        return ParagraphEndingQuery(
            ranges: endings, searchComparisons: match.comparisons,
            visitedEndings: visited
        )
    }
}
