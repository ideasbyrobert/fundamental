import CoreText
import FundamentalWrapping

@MainActor
struct NativeCodeLineSearch
{
    let text: NativeWrappingText
    let typesetter: CTTypesetter
    let opportunities: CodeWrappingOpportunities
    let sourceLine: WrappingSourceLine
    let start: Int
    let width: Double
    let inset: Double
    var cache: [Int: NativeWrappingLine] = [:]

    mutating func find() -> NativeWrappingLine?
    {
        let lower = text.source.boundaryIndex(atOrBefore: start)
        let upper = text.source.boundaryIndex(
            atOrBefore: sourceLine.contentRange.upperBound
        )
        if lower == upper
        {
            return fitting(upper)
        }
        let suggestion = CTTypesetterSuggestClusterBreakWithOffset(
            typesetter, start, width - inset, inset
        )
        let count = max(0, min(suggestion,
                              sourceLine.contentRange.upperBound - start))
        var index = min(upper, max(lower + 1,
            text.source.boundaryIndex(atOrBefore: start + count)))
        while index > lower, fitting(index) == nil
        {
            index -= 1
        }
        guard index > lower
        else
        {
            return nil
        }
        while index < upper, fitting(index + 1) != nil
        {
            index += 1
        }
        if index == upper
        {
            return fitting(index)
        }
        for priority in [CodeWrappingPriority.preferred, .secondary]
        {
            for candidate in stride(from: index, through: lower + 1, by: -1)
            {
                if priority == .secondary, candidate == lower + 1
                {
                    continue
                }
                let offset = text.source.graphemeBoundaries[candidate]
                if opportunities.priorities[offset] == priority,
                   let line = fitting(candidate)
                {
                    return line
                }
            }
        }
        return fitting(index)
    }

    mutating func fitting(_ index: Int) -> NativeWrappingLine?
    {
        if let line = cache[index]
        {
            return line.advance <= width - inset ? line : nil
        }
        let offset = text.source.graphemeBoundaries[index]
        let end = offset == sourceLine.contentRange.upperBound
            ? sourceLine.range.upperBound : offset
        guard let line = text.line(in: start ..< end, inlineOffset: inset)
        else
        {
            return nil
        }
        cache[index] = line
        return line.advance <= width - inset ? line : nil
    }
}
