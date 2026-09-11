import FundamentalParagraph
extension HyphenatedDisplay
{
    package func sources(in range: Range<Int>) throws -> [HyphenatedGlyphSource]
    {
        guard !range.isEmpty, range.lowerBound >= 0,
              range.upperBound <= units.count
        else
        {
            throw ExplicitShapingFailure.displayRange(range)
        }
        var result: [HyphenatedGlyphSource] = []
        let upper = min(range.upperBound, body.units.count)
        if range.lowerBound < upper
        {
            result = try body.sources(in: range.lowerBound..<upper)
                .map(HyphenatedGlyphSource.source)
        }
        if range.upperBound > body.units.count,
           case let .automatic(ink) = suffix
        {
            result.append(.generated(ink))
        }
        return result
    }
}
