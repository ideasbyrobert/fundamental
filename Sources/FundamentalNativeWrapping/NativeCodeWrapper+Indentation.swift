import FundamentalWrapping

extension NativeCodeWrapper
{
    mutating func indentation(for line: WrappingSourceLine) -> Double?
    {
        let start = line.contentRange.lowerBound
        var end = start
        while end < line.contentRange.upperBound,
              [9, 32].contains(text.source.utf16[end])
        {
            end += 1
        }
        guard let leading = text.line(in: start ..< end, inlineOffset: 0)
        else
        {
            return nil
        }
        measuredFragments += 1
        return min(leading.advance + unit,
                   width / CodeWrappingPolicy.indentationDivisor)
    }

    mutating func fit(
        _ start: Int, in line: WrappingSourceLine, inset: Double
    ) -> NativeWrappingLine?
    {
        var search = NativeCodeLineSearch(
            text: text, typesetter: typesetter, opportunities: opportunities,
            sourceLine: line, start: start, width: width, inset: inset
        )
        let result = search.find()
        measuredFragments += search.cache.count
        return result
    }
}
