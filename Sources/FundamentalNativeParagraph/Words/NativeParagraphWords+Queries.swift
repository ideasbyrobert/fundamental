import FundamentalParagraph
extension NativeParagraphWords
{
    package func matching(_ query: Range<Int>) throws -> [NativeWordObservation]
    {
        let text = source.source
        guard query.lowerBound >= 0, query.upperBound <= text.utf16.count,
              text.isBoundary(query.lowerBound),
              text.isBoundary(query.upperBound)
        else
        {
            throw WordScopeFailure.invalidQuery(query)
        }
        return observations.filter
        {
            let range = $0.resolution.range
            return query.isEmpty
                ? range.contains(query.lowerBound) : range.overlaps(query)
        }
    }
}
